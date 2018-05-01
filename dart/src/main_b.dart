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
  bool shoudColumnInset = false;

  for (int row = 0; row < 8; row++) {
    int startColumn = 0;

    if (shoudColumnInset) {
      startColumn = 1;
    }

    for (int column = startColumn; column < 8; column += 2) {
      currentCell.row = initialCell.row + row;
      currentCell.column = initialCell.column + column;

      if (projects[30].canPlace(city, currentCell)) {
        projects[30].place(city, currentCell);
      }
    }

    shoudColumnInset = !shoudColumnInset;
  }

  // place utility projects
  List<int> utilityProjects = [189, 128, 185, 104];

  int nextUtilityProject(int currentProjectIndex) {
    int nextProjectIndex = currentProjectIndex + 1;

    if (nextProjectIndex >= utilityProjects.length) {
      nextProjectIndex = 0;
    }

    return nextProjectIndex;
  }

  int currentProjectIndex = 0;
  int rowStartingProjectIndex = 1;
  int insetRowStartingProjectIndex = 0;

  shoudColumnInset = true;

  for (int row = 0; row < 8; row++) {
    int startColumn = 0;

    if (shoudColumnInset) {
      startColumn = 1;
    }

    for (int column = startColumn; column < 8; column += 2) {
      currentCell.row = initialCell.row + row;
      currentCell.column = initialCell.column + column;

      if (projects[utilityProjects[currentProjectIndex]]
          .canPlace(city, currentCell)) {
        projects[utilityProjects[currentProjectIndex]].place(city, currentCell);
      }

      currentProjectIndex = nextUtilityProject(currentProjectIndex);
    }

    shoudColumnInset = !shoudColumnInset;

    if (shoudColumnInset) {
      currentProjectIndex = nextUtilityProject(insetRowStartingProjectIndex);
      insetRowStartingProjectIndex++;
    } else {
      currentProjectIndex = nextUtilityProject(rowStartingProjectIndex);
      rowStartingProjectIndex++;
    }
  }
}

void placeDistricts(
  City city,
  List<Project> projects,
) {
  for (int row = 0; row < city.rows; row += 8) {
    for (int column = 0; column < city.columns; column += 8) {
      placeDistrict(
        city,
        new Cell(row, column),
        projects,
      );
    }
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
