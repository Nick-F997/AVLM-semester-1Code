from PIL import Image
import sys
import csv
import os
import scipy.io
import glob
import random
import numpy as np

OFFICE = "officePics/"
BASIC = "arucoBasic/"
CHALLENGING = "arucoChallenging/"

NEW_WIDTH = 227
NEW_HEIGHT = 227

def check_path(path: str) -> str:
    if path[-1] != '/':
        path += '/'
        return path
    return path 


def get_all_office_pics(path: str) -> list[str]:
    """
    Globs all the jpgs in the officePics folder
    """
    img_paths = glob.glob(path + "*.jpg")
    return img_paths


def create_new_imgs(img_path: str, aruco_paths: list[str], output_paths: list[str]) -> str:
    """
    Function to create new images with aruco tags embedded in them.
    """
    # Gets all the .jpgs of offices.
    raw_pics = get_all_office_pics(img_path)
    # This is for writing the .mat file
    basic_row = []
    complex_row = []

    # For filenames
    count = 0
    
    # Loop all the pictures
    for pic in raw_pics:
        ## Open two copies, one for basic one for complex
        img = Image.open(pic)
        img2 = Image.open(pic)
        w, h = img.size

        # Resize them to 227 x 227.
        l = (w - NEW_WIDTH) / 2
        t = (h - NEW_HEIGHT) / 2
        r = (w + NEW_WIDTH) / 2
        b = (h + NEW_HEIGHT) / 2

        img = img.crop((l, t, r, b))
        img2 = img2.crop((l, t, r, b))
        
        # Select random class and random image from that class
        class_selection = random.randint(0, 99)
        aruco_selection = random.randint(1, 100)

        # This image corrupted randomly, so I just excluded it.
        if class_selection == 72 and aruco_selection == 78:
            aruco_selection += 1

        class_str: str = str(class_selection) + '/'
        aruco_str: str = str(aruco_selection) + ".png"

        # Makes the image paths correct.
        if class_selection < 10:
            class_str = "0" + class_str
        
        if aruco_selection < 10:
            aruco_str = "000" + aruco_str
        elif aruco_selection == 100:
            aruco_str = "0" + aruco_str
        else:
            aruco_str = "00" + aruco_str

        # Full path for selections
        basic_selection = aruco_paths[0] + class_str + aruco_str
        complex_selection = aruco_paths[1] + class_str + aruco_str
        print(f"selected - {basic_selection}, {complex_selection}")

        # open both images, make them 34x34
        basic = Image.open(basic_selection)
        complex = Image.open(complex_selection)
        basic = basic.resize((34, 34))
        complex = complex.resize((34, 34))

        # random x and y positions, ensuring they don't go off the edge of the image
        pos_x = random.randint(0, NEW_WIDTH - 34)
        pos_y = random.randint(0, NEW_HEIGHT - 34)

        # stick aruco codes onto office pics
        img.paste(basic, (pos_x, pos_y))
        img2.paste(complex, (pos_x, pos_y))

        # new file names
        basic_filename = output_paths[0] + str(count) + ".png"
        complex_filename = output_paths[1] + str(count) + ".png"

        # Ensure they're the right size
        img = img.resize((227, 227))
        img2 = img2.resize((227, 227))

        #Save them
        img.save(basic_filename)
        img2.save(complex_filename)

        # Get the positional data for writing .mat file
        coord = np.array([pos_x, pos_y, 34, 34])
        
        # Append the data as a cell array with a matrix inside it for bBox
        basic_row.append({"fileNames": basic_filename, "bBox": [coord]})
        complex_row.append({"fileNames": complex_filename, "bBox": [coord]})

        # Increment file name
        count += 1
    
    # Create .mat paths
    basic_output_filename = output_paths[0] + "BBData.mat"
    complex_output_filename = output_paths[1] + "BBData.mat"

    # Create MATLAB table structure for basic and complex data
    basic_data_table = np.array([(row["fileNames"], row["bBox"]) for row in basic_row], dtype=[('fileNames', 'O'), ('bBox', 'O')])
    complex_data_table = np.array([(row["fileNames"], row["bBox"]) for row in complex_row], dtype=[('fileNames', 'O'), ('bBox', 'O')])

    # Scipy saves the files as .mats - this was a faf
    scipy.io.savemat(basic_output_filename, {"BBData": basic_data_table})
    scipy.io.savemat(complex_output_filename, {"BBData": complex_data_table})

    # Print the output file names
    print(basic_output_filename)
    print(complex_output_filename)

    return "MAT files created successfully."

# Example usage:
# create_new_imgs("path/to/images", ["path/to/aruco/basic/", "path/to/aruco/complex/"], ["path/to/output/basic/", "path/to/output/complex/"])



"""
Code to augment the provided blank office images with basic and complex aruco codes.
"""
def main(path: list[str]) -> int:
    # Check input args
    if len(path) != 3:
        print("Incorrect args. Please input imageData path and output path.")
        return 1
    
    # get path
    path_proper = path[-2]
    check_path(path_proper)

    #get output path
    output_path = path[-1]
    check_path(output_path)

    # Create all the input and output paths.
    output_path_basic = output_path + BASIC
    output_path_challenging = output_path + CHALLENGING
    path_office = path_proper + OFFICE
    path_basic = path_proper + BASIC
    path_chall = path_proper + CHALLENGING

    #print so you know they're going in the right place
    print(f"Office pics = {path_office}.")
    print(f"Basic pics = {path_basic}.")
    print(f"Challenging pics = {path_chall}.")

    print(f"output pics = {output_path_basic}, {output_path_challenging}.")

    # Create list of strings to pass to the heavy lifting function
    aruco_paths = [path_basic, path_chall]
    output_paths = [output_path_basic, output_path_challenging]

    # This does all the real work
    create_new_imgs(path_office, aruco_paths, output_paths)


# Standard python boilerplate
if __name__ == "__main__":
    sys.exit(main(sys.argv))