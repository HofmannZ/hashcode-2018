import numpy as np
import matplotlib.image
import random
import matplotlib.pyplot as plt

input_path = 'inputs/'
output_path = 'outputs/'

files = [
  'a_example',
  'b_short_walk',
  'c_going_green',
  'd_wide_selection',
  'e_precise_fit',
  'f_different_footprints'
]

extensions = [
  '.in',
  '.out'
]

file_a_in = input_path + files[0] + extensions[0]
file_a_out = output_path + files[0] + extensions[1]

with open(file_a_in) as f:
  file_a_content = f.readlines()

file_a_content = [x.strip() for x in file_a_content]
line_index = 0

class Building:
    building_type = 'R'
    height = 0
    width = 0
    capacity_or_type = 0

    def __init__(self, values, colors = [255, 0, 0]):
      [a, b, c, d] = values

      self.building_type = a
      self.height = b
      self.width = c
      self.capacity_or_type = d
      self.shape = np.zeros((b, c))
      self.colors = colors


def readLine():
  global line_index

  to_return = file_a_content[line_index]
  line_index += 1

  return to_return

def readLineAsListOfInts():
  line = readLine()

  return map(int, line.split())

def readBuldingInformation():
  values = readLine().split()

  return [values[0]] + list(map(int, values[1:4]))

def readBuildingRow():
  values = list(readLine())

  return [ord(x) for x in values]

num_lines, num_columns, max_distance, num_buildings = readLineAsListOfInts()

city_map = np.zeros((3, num_lines, num_columns))


from matplotlib.colors import ListedColormap, NoNorm
cmap = ListedColormap(['#E0E0E0', '#FF8C00', '#8c00FF', '#00FF8C'])

buildings = []

for building_id in range(num_buildings):
  newBuilding = Building(readBuldingInformation())

  if (newBuilding.building_type == 'R'):
    newBuilding.colors = [random.randint(150, 255), 100, 100]
  else:
    newBuilding.colors = [0, random.randint(50, 100), random.randint(150, 200)]

  for row_id in range(newBuilding.height):
    newBuilding.shape[row_id] = readBuildingRow()

  newBuilding.shape[newBuilding.shape == 46] = 0
  newBuilding.shape[newBuilding.shape == 35] = 1

  
  buildings.append(newBuilding)

line_index = 0

with open(file_a_out) as f:
  file_a_content = f.readlines()

file_a_content = [x.strip() for x in file_a_content]

num_of_projects = list(readLineAsListOfInts())[0]

for project_id in range(num_of_projects):

  building_id, left_x, left_y = readLineAsListOfInts()
  city_map[0][left_x : left_x + buildings[building_id].height, left_y : left_y + buildings[building_id].width] += buildings[building_id].shape * buildings[building_id].colors[0]
  city_map[1][left_x : left_x + buildings[building_id].height, left_y : left_y + buildings[building_id].width] += buildings[building_id].shape * buildings[building_id].colors[1]
  city_map[2][left_x : left_x + buildings[building_id].height, left_y : left_y + buildings[building_id].width] += buildings[building_id].shape * buildings[building_id].colors[2]


rgbArray = np.zeros((num_lines, num_columns, 3), 'uint8')
rgbArray[..., 0] = city_map[0]
rgbArray[..., 1] = city_map[1]
rgbArray[..., 2] = city_map[2]


# matplotlib.image.imsave('city.png', city_map.astype(np.uint8), cmap='gray')
img = plt.imshow(rgbArray)

plt.show()
# matplotlib.image.imsave(files[0] + '_city_map.png', city_map.astype(np.uint8), cmap='gray')
