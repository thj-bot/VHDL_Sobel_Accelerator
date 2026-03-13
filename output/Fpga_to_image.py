import numpy as np
import cv2

def convert_fpga_output_to_image(txt_file_path, output_image_path, width, height):
    print("FPGA verisi okunuyor, lütfen bekleyin...")
    
    with open(txt_file_path, 'r') as f:
        lines = f.readlines()
    
    pixels = [int(line.strip()) for line in lines if line.strip().isdigit()]
    
    expected_pixels = width * height
    if len(pixels) < expected_pixels:
        missing_pixels = expected_pixels - len(pixels)
        pixels = [0] * missing_pixels + pixels
    elif len(pixels) > expected_pixels:
        pixels = pixels[:expected_pixels]
        
    img_array = np.array(pixels, dtype=np.uint8).reshape((height, width))
    
    cv2.imwrite(output_image_path, img_array)
    print(f"ZAFER! FPGA çıktısı başarıyla resme dönüştürüldü: {output_image_path}")

if __name__ == "__main__":
    input_txt = "fpga_hardware_pixels.txt"
    output_img = "fpga_sonuc.jpg"
    
    convert_fpga_output_to_image(input_txt, output_img, 256, 256)