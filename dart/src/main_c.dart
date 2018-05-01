import 'dart:io';
import 'dart:convert';
import 'dart:async';

import 'package:args/args.dart';

class Cell {
  int row, column;

  // I ❤️ Dart for this
  Cell(
    this.row,
    this.column,
  );
}

class City {
  int rows, columns, maximumWalkingDistance, nBuildingPlans;
  List<List<int>> constructedBuildings, map;

  City(
    this.rows,
    this.columns,
    this.maximumWalkingDistance,
    this.nBuildingPlans,
    this.constructedBuildings,
  ) {
    this.map = new List();
    for (int row = 0; row < this.rows; row++) {
      this.map.add(new List());

      for (int column = 0; column < this.columns; column++) {
        this.map[row].add(-1);
      }
    }
  }
}

class Project {
  String type;
  int index, height, width, capacityOrService, surface;
  double efficiency;
  List<Cell> occupidCells = new List();

  // Dart is amamzing!
  Project(
    this.index,
    this.type,
    this.height,
    this.width,
    this.capacityOrService,
  ) {
    this.surface = this.height * this.width;

    if (this.type == 'R') {
      this.efficiency = this.capacityOrService / this.surface;
    } else {
      this.efficiency = 1 / this.surface;
    }
  }

  void parseAndAddRowOfCells(int index, String rawRow) {
    for (int i = 0; i < rawRow.length; i++) {
      if (rawRow[i] == '#') {
        Cell cell = new Cell(index, i);
        occupidCells.add(cell);
      }
    }
  }

  bool canPlace(City city, Cell cell) {
    // is outside of the city map
    if (cell.column < 0 ||
        cell.row < 0 ||
        cell.column + this.width > city.columns ||
        cell.row + this.height > city.rows) {
      return false;
    }

    // check all occupid cells
    for (int i = 0; i < this.occupidCells.length; i++) {
      if (city.map[cell.row + this.occupidCells[i].row]
              [cell.column + this.occupidCells[i].column] !=
          -1) {
        return false;
      }
    }

    return true;
  }

  void place(City city, Cell cell) {
    city.constructedBuildings.add([
      this.index,
      cell.row,
      cell.column,
    ]);

    for (int i = 0; i < this.occupidCells.length; i++) {
      city.map[this.occupidCells[i].row + cell.row]
          [this.occupidCells[i].column + cell.column] = this.index;
    }
  }
}

Future main(List<String> args) async {
  exitCode = 0; // presume success

  // parse arguments
  final ArgParser parser = new ArgParser();
  parser.addOption('input');
  parser.addOption('output');

  ArgResults argResults = parser.parse(args);

  // parse input lines
  Stream inputLines = new File(argResults['input'])
      .openRead()
      .transform(UTF8.decoder)
      .transform(const LineSplitter());

  var parsedInput = await parseInput(inputLines);

  City city = parsedInput[0];
  List<Project> projects = parsedInput[1];

  placeDistricts(
    city,
    projects,
  );

  // divide the pojects in two lists
  List<Project> residentialProjects = getResidentialProjects(projects);

  // iterate over all residential projects form most efficient to least efficient
  for (int i = 0; i < residentialProjects.length; i++) {
    placeResidentialProjects(
      city,
      residentialProjects,
      currentResidentialProject: i,
    );
  }

  IOSink outputSink = new File(argResults['output']).openWrite();

  await printOutput(outputSink, city);

  // close streams
  outputSink.close();
}

Future parseInput(Stream inputLines) async {
  int lineIndex = 0;
  int nextParsingProject = 0;
  int lineInParsingProject = 0;

  City city;
  List<Project> projects;

  try {
    await for (String line in inputLines) {
      List<String> lineItems = line.split(' ');

      if (lineIndex == 0) {
        city = new City(
          int.parse(lineItems[0]),
          int.parse(lineItems[1]),
          int.parse(lineItems[2]),
          int.parse(lineItems[3]),
          new List(),
        );

        projects = new List(city.nBuildingPlans);
      } else {
        if (lineInParsingProject == 0) {
          String type = lineItems[0];
          int height = int.parse(lineItems[1]);
          int width = int.parse(lineItems[2]);
          int capacityOrService = int.parse(lineItems[3]);

          projects[nextParsingProject] = new Project(
            nextParsingProject,
            type,
            height,
            width,
            capacityOrService,
          );

          nextParsingProject++;
          lineInParsingProject++;
        } else {
          Project currentProject = projects[nextParsingProject - 1];
          currentProject.parseAndAddRowOfCells(
            lineInParsingProject - 1,
            line,
          );

          // reset the parsing line
          if (lineInParsingProject == currentProject.height) {
            lineInParsingProject = 0;
          } else {
            lineInParsingProject++;
          }
        }
      }

      lineIndex++;
    }
  } catch (err) {
    stdout.writeln(err);
    exitCode = 2;
  }

  return [city, projects];
}

Future printOutput(IOSink outputSink, City city) async {
  await outputSink.writeln(city.constructedBuildings.length);

  for (int i = 0; i < city.constructedBuildings.length; i++) {
    await outputSink.write(city.constructedBuildings[i][0]);
    await outputSink.write(' ');
    await outputSink.write(city.constructedBuildings[i][1]);
    await outputSink.write(' ');
    await outputSink.write(city.constructedBuildings[i][2]);
    await outputSink.write('\n');
  }
}

List<Project> getResidentialProjects(List<Project> projects) {
  List<Project> residentialProjects = new List.from(projects);
  residentialProjects.retainWhere((Project project) => project.type == 'R');

  return residentialProjects;
}

void sortProjects(List<Project> project) {
  project.sort((a, b) => b.efficiency.compareTo(a.efficiency));
}

void placeDistrict(
  City city,
  Cell initialCell,
  List<Project> projects,
) {
  Cell currentCell = new Cell(0, 0);

  // place residential projects
  currentCell.row = initialCell.row + 20;
  currentCell.column = initialCell.column + 20;

  if (projects[7].canPlace(city, currentCell)) {
    projects[7].place(city, currentCell);
  }

  currentCell.row = initialCell.row + 8;
  currentCell.column = initialCell.column + 13;

  if (projects[7].canPlace(city, currentCell)) {
    projects[7].place(city, currentCell);
  }

  currentCell.row = initialCell.row + 8;
  currentCell.column = initialCell.column + 15;

  if (projects[7].canPlace(city, currentCell)) {
    projects[7].place(city, currentCell);
  }

  currentCell.row = initialCell.row + 12;
  currentCell.column = initialCell.column + 9;

  if (projects[7].canPlace(city, currentCell)) {
    projects[7].place(city, currentCell);
  }

  currentCell.row = initialCell.row + 12;
  currentCell.column = initialCell.column + 11;

  if (projects[7].canPlace(city, currentCell)) {
    projects[7].place(city, currentCell);
  }

  currentCell.row = initialCell.row + 12;
  currentCell.column = initialCell.column + 13;

  if (projects[7].canPlace(city, currentCell)) {
    projects[7].place(city, currentCell);
  }

  currentCell.row = initialCell.row + 12;
  currentCell.column = initialCell.column + 15;

  if (projects[7].canPlace(city, currentCell)) {
    projects[7].place(city, currentCell);
  }

  currentCell.row = initialCell.row + 11;
  currentCell.column = initialCell.column + 30;

  if (projects[7].canPlace(city, currentCell)) {
    projects[7].place(city, currentCell);
  }

  currentCell.row = initialCell.row + 18;
  currentCell.column = initialCell.column + 3;

  if (projects[7].canPlace(city, currentCell)) {
    projects[7].place(city, currentCell);
  }

  currentCell.row = initialCell.row + 20;
  currentCell.column = initialCell.column + 1;

  if (projects[7].canPlace(city, currentCell)) {
    projects[7].place(city, currentCell);
  }

  currentCell.row = initialCell.row + 25;
  currentCell.column = initialCell.column + 6;

  if (projects[7].canPlace(city, currentCell)) {
    projects[7].place(city, currentCell);
  }

  currentCell.row = initialCell.row + 25;
  currentCell.column = initialCell.column + 8;

  if (projects[7].canPlace(city, currentCell)) {
    projects[7].place(city, currentCell);
  }

  currentCell.row = initialCell.row + 28;
  currentCell.column = initialCell.column + 10;

  if (projects[7].canPlace(city, currentCell)) {
    projects[7].place(city, currentCell);
  }

  currentCell.row = initialCell.row + 28;
  currentCell.column = initialCell.column + 12;

  if (projects[7].canPlace(city, currentCell)) {
    projects[7].place(city, currentCell);
  }

  currentCell.row = initialCell.row + 35;
  currentCell.column = initialCell.column + 16;

  if (projects[7].canPlace(city, currentCell)) {
    projects[7].place(city, currentCell);
  }

  currentCell.row = initialCell.row + 35;
  currentCell.column = initialCell.column + 18;

  if (projects[7].canPlace(city, currentCell)) {
    projects[7].place(city, currentCell);
  }

  currentCell.row = initialCell.row + 35;
  currentCell.column = initialCell.column + 20;

  if (projects[7].canPlace(city, currentCell)) {
    projects[7].place(city, currentCell);
  }

  currentCell.row = initialCell.row + 39;
  currentCell.column = initialCell.column + 20;

  if (projects[7].canPlace(city, currentCell)) {
    projects[7].place(city, currentCell);
  }

  currentCell.row = initialCell.row + 37;
  currentCell.column = initialCell.column + 22;

  if (projects[7].canPlace(city, currentCell)) {
    projects[7].place(city, currentCell);
  }

  currentCell.row = initialCell.row + 27;
  currentCell.column = initialCell.column + 31;

  if (projects[7].canPlace(city, currentCell)) {
    projects[7].place(city, currentCell);
  }

  currentCell.row = initialCell.row + 30;
  currentCell.column = initialCell.column + 27;

  if (projects[7].canPlace(city, currentCell)) {
    projects[7].place(city, currentCell);
  }

  currentCell.row = initialCell.row + 30;
  currentCell.column = initialCell.column + 29;

  if (projects[7].canPlace(city, currentCell)) {
    projects[7].place(city, currentCell);
  }

  // place utility projects
  currentCell.row = initialCell.row + 19;
  currentCell.column = initialCell.column + 20;

  if (projects[142].canPlace(city, currentCell)) {
    projects[142].place(city, currentCell);
  }

  currentCell.row = initialCell.row + 27;
  currentCell.column = initialCell.column + 29;

  if (projects[185].canPlace(city, currentCell)) {
    projects[185].place(city, currentCell);
  }

  currentCell.row = initialCell.row + 27;
  currentCell.column = initialCell.column + 30;

  if (projects[112].canPlace(city, currentCell)) {
    projects[112].place(city, currentCell);
  }

  currentCell.row = initialCell.row + 27;
  currentCell.column = initialCell.column + 27;

  if (projects[195].canPlace(city, currentCell)) {
    projects[195].place(city, currentCell);
  }

  currentCell.row = initialCell.row + 26;
  currentCell.column = initialCell.column + 27;

  if (projects[199].canPlace(city, currentCell)) {
    projects[199].place(city, currentCell);
  }

  currentCell.row = initialCell.row + 7;
  currentCell.column = initialCell.column + 17;
  if (projects[180].canPlace(city, currentCell)) {
    projects[180].place(city, currentCell);
  }

  currentCell.row = initialCell.row + 7;
  currentCell.column = initialCell.column + 18;

  if (projects[193].canPlace(city, currentCell)) {
    projects[193].place(city, currentCell);
  }

  currentCell.row = initialCell.row + 5;
  currentCell.column = initialCell.column + 19;
  if (projects[118].canPlace(city, currentCell)) {
    projects[118].place(city, currentCell);
  }

  currentCell.row = initialCell.row + 19;
  currentCell.column = initialCell.column + 22;

  if (projects[166].canPlace(city, currentCell)) {
    projects[166].place(city, currentCell);
  }

  currentCell.row = initialCell.row + 24;
  currentCell.column = initialCell.column + 3;

  if (projects[188].canPlace(city, currentCell)) {
    projects[188].place(city, currentCell);
  }

  currentCell.row = initialCell.row + 9;
  currentCell.column = initialCell.column + 25;

  if (projects[169].canPlace(city, currentCell)) {
    projects[169].place(city, currentCell);
  }

  currentCell.row = initialCell.row + 25;
  currentCell.column = initialCell.column + 11;

  if (projects[184].canPlace(city, currentCell)) {
    projects[184].place(city, currentCell);
  }

  currentCell.row = initialCell.row + 22;
  currentCell.column = initialCell.column + 3;

  if (projects[104].canPlace(city, currentCell)) {
    projects[104].place(city, currentCell);
  }

  currentCell.row = initialCell.row + 1;
  currentCell.column = initialCell.column + 20;

  if (projects[111].canPlace(city, currentCell)) {
    projects[111].place(city, currentCell);
  }

  currentCell.row = initialCell.row + 15;
  currentCell.column = initialCell.column + 25;

  if (projects[152].canPlace(city, currentCell)) {
    projects[152].place(city, currentCell);
  }

  currentCell.row = initialCell.row + 4;
  currentCell.column = initialCell.column + 22;
  if (projects[101].canPlace(city, currentCell)) {
    projects[101].place(city, currentCell);
  }

  currentCell.row = initialCell.row + 28;
  currentCell.column = initialCell.column + 14;

  if (projects[121].canPlace(city, currentCell)) {
    projects[121].place(city, currentCell);
  }

  currentCell.row = initialCell.row + 20;
  currentCell.column = initialCell.column + 27;

  if (projects[137].canPlace(city, currentCell)) {
    projects[137].place(city, currentCell);
  }

  currentCell.row = initialCell.row + 20;
  currentCell.column = initialCell.column + 22;

  if (projects[124].canPlace(city, currentCell)) {
    projects[124].place(city, currentCell);
  }

  currentCell.row = initialCell.row + 16;
  currentCell.column = initialCell.column + 5;

  if (projects[146].canPlace(city, currentCell)) {
    projects[146].place(city, currentCell);
  }
}

void placeDistricts(
  City city,
  List<Project> projects,
) {
  bool shoudInsetColumn = false;

  for (int row = -21; row < city.rows + 21; row += 21) {
    int startColumn = -21;

    if (shoudInsetColumn) {
      startColumn += 21;
    }

    for (int column = startColumn; column < city.columns + 21; column += 42) {
      placeDistrict(
        city,
        new Cell(row, column),
        projects,
      );
    }

    shoudInsetColumn = !shoudInsetColumn;
  }
}

void placeResidentialProjects(
  City city,
  List<Project> residentialProjects, {
  int currentResidentialProject,
}) {
  for (int row = 0; row < city.rows; row++) {
    for (int column = 0; column < city.columns; column++) {
      Cell cell = new Cell(row, column);

      if (residentialProjects[currentResidentialProject].canPlace(city, cell)) {
        residentialProjects[currentResidentialProject].place(city, cell);
      }
    }
  }
}
