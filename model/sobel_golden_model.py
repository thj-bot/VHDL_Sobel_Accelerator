"""
FPGA Sobel Edge Detection - Golden Model
========================================
Software reference model for VHDL-based FPGA hardware accelerator.
Implements Sobel edge detection algorithm with hardware-friendly optimizations.

Author: Batuhan Kirtac
"""

import numpy as np
import cv2
import math


def sobel_golden_model(input_image_path, output_true_magnitude_path,
                       output_hardware_friendly_path, original_pixels_path,
                       hardware_pixels_path):
    """
    Apply Sobel edge detection using hardware-simulating approach.
    
    Args:
        input_image_path: Path to input grayscale image
        output_true_magnitude_path: Path for true magnitude output image
        output_hardware_friendly_path: Path for hardware-friendly output image
        original_pixels_path: Path for original pixels text file
        hardware_pixels_path: Path for hardware pixels text file
        
    Returns:
        tuple: (true_magnitude_output, hardware_friendly_output)
    """
    try:
        img = cv2.imread(input_image_path, cv2.IMREAD_GRAYSCALE)
        if img is None:
            raise FileNotFoundError(f"Input image not found: {input_image_path}")
    except Exception as e:
        raise RuntimeError(f"Error reading input image: {e}")
    
    height, width = img.shape
    
    # Sobel kernels for gradient calculation
    gx_kernel = np.array([[-1, 0, 1],
                          [-2, 0, 2],
                          [-1, 0, 1]])
    
    gy_kernel = np.array([[-1, -2, -1],
                          [ 0,  0,  0],
                          [ 1,  2,  1]])
    
    true_magnitude_output = np.zeros((height, width), dtype=np.uint8)
    hardware_friendly_output = np.zeros((height, width), dtype=np.uint8)
    
    try:
        with open(original_pixels_path, 'w') as f:
            for row in range(height):
                for col in range(width):
                    f.write(f"{img[row, col]}\n")
    except Exception as e:
        raise RuntimeError(f"Error writing original pixels file: {e}")
    
    try:
        with open(hardware_pixels_path, 'w') as f:
            # Process pixels using 3x3 sliding window to simulate hardware line buffers
            for row in range(height):
                for col in range(width):
                    # Skip border pixels where 3x3 kernel cannot be applied
                    if row == 0 or row == height - 1 or col == 0 or col == width - 1:
                        gx = 0
                        gy = 0
                    else:
                        # Manual 3x3 convolution using nested loops
                        gx = 0
                        gy = 0
                        for i in range(-1, 2):  # kernel rows
                            for j in range(-1, 2):  # kernel columns
                                pixel_value = img[row + i, col + j]
                                gx += pixel_value * gx_kernel[i + 1, j + 1]
                                gy += pixel_value * gy_kernel[i + 1, j + 1]
                    
                    # True magnitude calculation (computationally expensive for hardware)
                    true_magnitude = int(math.sqrt(gx**2 + gy**2))
                    true_magnitude = min(255, max(0, true_magnitude))
                    true_magnitude_output[row, col] = true_magnitude
                    
                    # Hardware-friendly magnitude approximation using Manhattan distance
                    hardware_friendly = abs(gx) + abs(gy)
                    hardware_friendly = min(255, max(0, hardware_friendly))
                    hardware_friendly_output[row, col] = hardware_friendly
                    
                    f.write(f"{hardware_friendly}\n")
    except Exception as e:
        raise RuntimeError(f"Error writing hardware pixels file: {e}")
    
    try:
        cv2.imwrite(output_true_magnitude_path, true_magnitude_output)
        cv2.imwrite(output_hardware_friendly_path, hardware_friendly_output)
    except Exception as e:
        raise RuntimeError(f"Error saving output images: {e}")
    
    print(f"True magnitude image saved to: {output_true_magnitude_path}")
    print(f"Hardware-friendly image saved to: {output_hardware_friendly_path}")
    print(f"Original pixels exported to: {original_pixels_path}")
    print(f"Hardware pixels exported to: {hardware_pixels_path}")
    
    return true_magnitude_output, hardware_friendly_output


if __name__ == "__main__":
    input_image = "karetestmalzemesi.png"
    output_true = "true_magnitude_output.jpg"
    output_hw = "hardware_friendly_output.jpg"
    original_pixels = "original_pixels.txt"
    hardware_pixels = "hardware_pixels.txt"
    
    try:
        true_mag, hw_friendly = sobel_golden_model(
            input_image, output_true, output_hw, original_pixels, hardware_pixels
        )
        print("Sobel edge detection completed successfully!")
    except Exception as e:
        print(f"Error: {e}")
