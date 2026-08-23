import argparse
import json
import math
import os
import sys
from pathlib import Path

import cv2
import numpy as np


ANALYSIS_WIDTH = 640
HASH_SIZE = 16


def report(event, **values):
    print(json.dumps({"event": event, **values}), flush=True)


def analyse_frame(frame):
    height, width = frame.shape[:2]
    scale = min(1.0, ANALYSIS_WIDTH / width)
    if scale < 1.0:
        frame = cv2.resize(frame, (ANALYSIS_WIDTH, round(height * scale)), interpolation=cv2.INTER_AREA)

    gray = cv2.cvtColor(frame, cv2.COLOR_BGR2GRAY)
    sharpness = math.log1p(cv2.Laplacian(gray, cv2.CV_64F).var())
    brightness = float(gray.mean())
    exposure = max(0.0, 1.0 - abs(brightness - 127.5) / 127.5)
    clipped = float(np.mean((gray < 8) | (gray > 247)))
    score = sharpness * (0.55 + 0.45 * exposure) * (1.0 - min(clipped, 0.8))

    small = cv2.resize(gray, (HASH_SIZE + 1, HASH_SIZE), interpolation=cv2.INTER_AREA)
    difference_hash = np.packbits(small[:, 1:] > small[:, :-1]).tobytes()
    return score, difference_hash


def hash_distance(first, second):
    return sum((left ^ right).bit_count() for left, right in zip(first, second))


def choose_frames(candidates, previous_hash, frames_per_second):
    candidates.sort(key=lambda candidate: candidate[0], reverse=True)
    selected = []

    for candidate in candidates:
        candidate_hash = candidate[2]
        if previous_hash is not None and hash_distance(candidate_hash, previous_hash) < 12:
            continue
        if any(hash_distance(candidate_hash, item[2]) < 18 for item in selected):
            continue
        selected.append(candidate)
        if len(selected) == frames_per_second:
            break

    if not selected and candidates:
        selected.append(candidates[0])
    return sorted(selected, key=lambda candidate: candidate[1])


def write_window(candidates, previous_hash, output_directory, frames_per_second, saved_count):
    selected = choose_frames(candidates, previous_hash, frames_per_second)
    for score, timestamp, difference_hash, frame in selected:
        saved_count += 1
        filename = f"frame_{saved_count:06d}_{timestamp:010.3f}s.jpg"
        destination = output_directory / filename
        if not cv2.imwrite(str(destination), frame, [cv2.IMWRITE_JPEG_QUALITY, 95]):
            raise RuntimeError(f"Could not write {destination}")
        previous_hash = difference_hash
    return previous_hash, saved_count


def extract_frames(video_path, output_directory, frames_per_second):
    capture = cv2.VideoCapture(str(video_path))
    if not capture.isOpened():
        raise RuntimeError("The selected video could not be opened")

    source_fps = capture.get(cv2.CAP_PROP_FPS)
    frame_count = int(capture.get(cv2.CAP_PROP_FRAME_COUNT))
    if source_fps <= 0:
        raise RuntimeError("The selected video does not report a valid frame rate")

    duration = frame_count / source_fps if frame_count > 0 else 0.0
    report("started", sourceFps=source_fps, totalFrames=frame_count, durationSeconds=duration)

    current_second = 0
    frame_index = 0
    saved_count = 0
    candidates = []
    previous_hash = None

    while True:
        success, frame = capture.read()
        if not success:
            break

        timestamp = frame_index / source_fps
        frame_second = int(timestamp)
        if frame_second != current_second:
            previous_hash, saved_count = write_window(
                candidates, previous_hash, output_directory, frames_per_second, saved_count
            )
            candidates = []
            current_second = frame_second

        score, difference_hash = analyse_frame(frame)
        candidates.append((score, timestamp, difference_hash, frame.copy()))
        candidates.sort(key=lambda candidate: candidate[0], reverse=True)
        del candidates[12:]

        frame_index += 1
        if frame_index % max(1, round(source_fps / 2)) == 0:
            progress = frame_index / frame_count if frame_count > 0 else 0.0
            report(
                "progress",
                progress=min(progress, 1.0),
                processedFrames=frame_index,
                totalFrames=frame_count,
                savedFrames=saved_count,
            )

    if candidates:
        previous_hash, saved_count = write_window(
            candidates, previous_hash, output_directory, frames_per_second, saved_count
        )
    capture.release()

    if saved_count == 0:
        raise RuntimeError("No usable frames were found in the selected video")
    report("complete", progress=1.0, savedFrames=saved_count, outputDirectory=str(output_directory))


def parse_arguments():
    parser = argparse.ArgumentParser(description="Select clear, diverse photogrammetry frames from a video")
    parser.add_argument("video", type=Path)
    parser.add_argument("output", type=Path)
    parser.add_argument("--frames-per-second", type=int, default=3, choices=(3, 4))
    return parser.parse_args()


def main():
    arguments = parse_arguments()
    if not arguments.video.is_file():
        report("error", message="The selected video does not exist")
        return 2

    arguments.output.mkdir(parents=True, exist_ok=True)
    try:
        extract_frames(arguments.video, arguments.output, arguments.frames_per_second)
        return 0
    except Exception as error:
        report("error", message=str(error))
        return 1


if __name__ == "__main__":
    sys.exit(main())
