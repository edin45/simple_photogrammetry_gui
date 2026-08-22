#define STB_IMAGE_IMPLEMENTATION
#include "stb_image.h"
#define STB_IMAGE_WRITE_IMPLEMENTATION
#include "stb_image_write.h"
#define STB_IMAGE_RESIZE_IMPLEMENTATION
#include "deprecated/stb_image_resize.h"

#include <iostream>
#include <vector>
#include <string>
#include <filesystem>
#include <thread>
#include <atomic>

namespace fs = std::filesystem;

void processImages(const std::vector<fs::path>& files, const fs::path& destDir, int maxSize, std::atomic<size_t>& index, std::atomic<size_t>& completed) {
    size_t i;
    
    // Lock-free work-stealing queue
    while ((i = index.fetch_add(1, std::memory_order_relaxed)) < files.size()) {
        const auto& file = files[i];
        
        // 1. Force the output extension to be .png
        fs::path outPath = destDir / file.stem(); 
        outPath += ".png";                        

        int width, height, channels;
        unsigned char* img = stbi_load(file.string().c_str(), &width, &height, &channels, 0);
        
        if (!img) continue;

        if (width <= maxSize && height <= maxSize) {
            // Write original pixels to PNG (stride = width * channels)
            stbi_write_png(outPath.string().c_str(), width, height, channels, img, width * channels);
            stbi_image_free(img);
            completed.fetch_add(1, std::memory_order_relaxed);
            continue;
        }

        int tWidth = width, tHeight = height;
        if (width > height) {
            tWidth = maxSize;
            tHeight = (height * maxSize) / width;
        } else {
            tHeight = maxSize;
            tWidth = (width * maxSize) / height;
        }

        unsigned char* resized = (unsigned char*)malloc(tWidth * tHeight * channels);
        
        stbir_resize_uint8(img, width, height, 0, resized, tWidth, tHeight, 0, channels);
        
        // 2. Write resized pixels to PNG
        stbi_write_png(outPath.string().c_str(), tWidth, tHeight, channels, resized, tWidth * channels);

        free(resized);
        stbi_image_free(img);
        
        completed.fetch_add(1, std::memory_order_relaxed);
    }
}

int main(int argc, char** argv) {
    if (argc != 5) {
        std::cerr << "Usage: fast_downscaler <source_dir> <dest_dir> <max_size> <threads>\n";
        return 1;
    }
    
    stbi_write_png_compression_level = 2;

    fs::path sourceDir = argv[1];
    fs::path destDir = argv[2];
    int maxSize = std::stoi(argv[3]);
    int threadCount = std::stoi(argv[4]);

    if (!fs::exists(destDir)) {
        fs::create_directories(destDir);
    }

    std::vector<fs::path> files;
    for (const auto& entry : fs::directory_iterator(sourceDir)) {
        std::string ext = entry.path().extension().string();
        for(auto& c : ext) c = tolower(c);
        if (ext == ".jpg" || ext == ".jpeg" || ext == ".png") {
            files.push_back(entry.path());
        }
    }

    if (files.empty()) return 0;

    std::atomic<size_t> currentIndex(0);
    std::atomic<size_t> completed(0);
    std::vector<std::thread> workers;

    std::cout << "Processing " << files.size() << " images on " << threadCount << " threads...\n";

    for (int i = 0; i < threadCount; i++) {
        workers.emplace_back(processImages, std::ref(files), std::ref(destDir), maxSize, std::ref(currentIndex), std::ref(completed));
    }

    for (auto& t : workers) {
        t.join();
    }

    std::cout << "Successfully resized " << completed.load() << " images.\n";
    return 0;
}
