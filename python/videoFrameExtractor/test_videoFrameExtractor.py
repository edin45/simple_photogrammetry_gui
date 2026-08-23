import tempfile
import unittest
from pathlib import Path

import cv2
import numpy as np

from videoFrameExtractor import extract_frames, hash_distance


class VideoFrameExtractorTest(unittest.TestCase):
    def test_hash_distance_detects_matching_and_different_frames(self):
        first = bytes([0b10101010, 0b11110000])
        second = bytes([0b10101010, 0b11110000])
        third = bytes([0b01010101, 0b00001111])

        self.assertEqual(hash_distance(first, second), 0)
        self.assertEqual(hash_distance(first, third), 16)

    def test_extracts_up_to_three_clear_frames_per_second(self):
        with tempfile.TemporaryDirectory() as temporary_directory:
            temporary_path = Path(temporary_directory)
            video_path = temporary_path / "capture.avi"
            output_path = temporary_path / "frames"
            output_path.mkdir()

            writer = cv2.VideoWriter(
                str(video_path),
                cv2.VideoWriter_fourcc(*"MJPG"),
                30,
                (320, 240),
            )
            self.assertTrue(writer.isOpened())
            random = np.random.default_rng(42)
            base = random.integers(0, 256, (240, 320, 3), dtype=np.uint8)
            for frame_index in range(60):
                shift = frame_index * 2
                frame = np.roll(base, shift, axis=1)
                if frame_index % 10 == 0:
                    frame = cv2.GaussianBlur(frame, (31, 31), 0)
                writer.write(frame)
            writer.release()

            extract_frames(video_path, output_path, 3)

            images = sorted(output_path.glob("*.jpg"))
            self.assertGreaterEqual(len(images), 2)
            self.assertLessEqual(len(images), 6)
            self.assertTrue(all(cv2.imread(str(image)) is not None for image in images))


if __name__ == "__main__":
    unittest.main()
