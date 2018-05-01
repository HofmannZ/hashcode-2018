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

  // place utility project
  currentCell.row = initialCell.row + 0;
  currentCell.column = initialCell.column + 3;

  if (projects[151].canPlace(city, currentCell)) {
    projects[151].place(city, currentCell);
  }

  currentCell.row = initialCell.row + 0;
  currentCell.column = initialCell.column + 4;

  if (projects[178].canPlace(city, currentCell)) {
    projects[178].place(city, currentCell);
  }

  currentCell.row = initialCell.row + 0;
  currentCell.column = initialCell.column + 5;

  if (projects[185].canPlace(city, currentCell)) {
    projects[185].place(city, currentCell);
  }

  currentCell.row = initialCell.row + 0;
  currentCell.column = initialCell.column + 6;

  if (projects[182].canPlace(city, currentCell)) {
    projects[182].place(city, currentCell);
  }

  currentCell.row = initialCell.row + 0;
  currentCell.column = initialCell.column + 7;

  if (projects[132].canPlace(city, currentCell)) {
    projects[132].place(city, currentCell);
  }

  currentCell.row = initialCell.row + 0;
  currentCell.column = initialCell.column + 8;

  if (projects[184].canPlace(city, currentCell)) {
    projects[184].place(city, currentCell);
  }

  currentCell.row = initialCell.row + 0;
  currentCell.column = initialCell.column + 9;

  if (projects[193].canPlace(city, currentCell)) {
    projects[193].place(city, currentCell);
  }

  currentCell.row = initialCell.row + 4;
  currentCell.column = initialCell.column + 0;

  if (projects[159].canPlace(city, currentCell)) {
    projects[159].place(city, currentCell);
  }

  currentCell.row = initialCell.row + 4;
  currentCell.column = initialCell.column + 4;

  if (projects[177].canPlace(city, currentCell)) {
    projects[177].place(city, currentCell);
  }

  currentCell.row = initialCell.row + 8;
  currentCell.column = initialCell.column + 2;

  if (projects[128].canPlace(city, currentCell)) {
    projects[128].place(city, currentCell);
  }

  currentCell.row = initialCell.row + 8;
  currentCell.column = initialCell.column + 4;

  if (projects[180].canPlace(city, currentCell)) {
    projects[180].place(city, currentCell);
  }

  currentCell.row = initialCell.row + 8;
  currentCell.column = initialCell.column + 6;

  if (projects[119].canPlace(city, currentCell)) {
    projects[119].place(city, currentCell);
  }

  currentCell.row = initialCell.row + 8;
  currentCell.column = initialCell.column + 8;

  if (projects[123].canPlace(city, currentCell)) {
    projects[123].place(city, currentCell);
  }

  // place residential projects
  currentCell.row = initialCell.row + 0;
  currentCell.column = initialCell.column + 0;

  if (projects[13].canPlace(city, currentCell)) {
    projects[13].place(city, currentCell);
  }

  currentCell.row = initialCell.row + 0;
  currentCell.column = initialCell.column + 1;

  if (projects[13].canPlace(city, currentCell)) {
    projects[13].place(city, currentCell);
  }

  currentCell.row = initialCell.row + 0;
  currentCell.column = initialCell.column + 2;

  if (projects[13].canPlace(city, currentCell)) {
    projects[13].place(city, currentCell);
  }

  currentCell.row = initialCell.row + 0;
  currentCell.column = initialCell.column + 10;

  if (projects[13].canPlace(city, currentCell)) {
    projects[13].place(city, currentCell);
  }

  currentCell.row = initialCell.row + 0;
  currentCell.column = initialCell.column + 11;

  if (projects[13].canPlace(city, currentCell)) {
    projects[13].place(city, currentCell);
  }

  currentCell.row = initialCell.row + 4;
  currentCell.column = initialCell.column + 8;

  if (projects[49].canPlace(city, currentCell)) {
    projects[49].place(city, currentCell);
  }

  currentCell.row = initialCell.row + 5;
  currentCell.column = initialCell.column + 0;

  if (projects[7].canPlace(city, currentCell)) {
    projects[7].place(city, currentCell);
  }

  currentCell.row = initialCell.row + 5;
  currentCell.column = initialCell.column + 2;

  if (projects[7].canPlace(city, currentCell)) {
    projects[7].place(city, currentCell);
  }

  currentCell.row = initialCell.row + 5;
  currentCell.column = initialCell.column + 4;

  if (projects[7].canPlace(city, currentCell)) {
    projects[7].place(city, currentCell);
  }

  currentCell.row = initialCell.row + 5;
  currentCell.column = initialCell.column + 6;

  if (projects[7].canPlace(city, currentCell)) {
    projects[7].place(city, currentCell);
  }

  currentCell.row = initialCell.row + 5;
  currentCell.column = initialCell.column + 8;

  if (projects[7].canPlace(city, currentCell)) {
    projects[7].place(city, currentCell);
  }

  currentCell.row = initialCell.row + 5;
  currentCell.column = initialCell.column + 10;

  if (projects[7].canPlace(city, currentCell)) {
    projects[7].place(city, currentCell);
  }

  currentCell.row = initialCell.row + 7;
  currentCell.column = initialCell.column + 0;

  if (projects[49].canPlace(city, currentCell)) {
    projects[49].place(city, currentCell);
  }

  currentCell.row = initialCell.row + 7;
  currentCell.column = initialCell.column + 4;

  if (projects[49].canPlace(city, currentCell)) {
    projects[49].place(city, currentCell);
  }

  currentCell.row = initialCell.row + 7;
  currentCell.column = initialCell.column + 8;

  if (projects[49].canPlace(city, currentCell)) {
    projects[49].place(city, currentCell);
  }

  currentCell.row = initialCell.row + 7;
  currentCell.column = initialCell.column + 0;

  if (projects[49].canPlace(city, currentCell)) {
    projects[49].place(city, currentCell);
  }

  currentCell.row = initialCell.row + 8;
  currentCell.column = initialCell.column + 0;

  if (projects[7].canPlace(city, currentCell)) {
    projects[7].place(city, currentCell);
  }

  currentCell.row = initialCell.row + 8;
  currentCell.column = initialCell.column + 10;

  if (projects[7].canPlace(city, currentCell)) {
    projects[7].place(city, currentCell);
  }

  currentCell.row = initialCell.row + 10;
  currentCell.column = initialCell.column + 0;

  if (projects[7].canPlace(city, currentCell)) {
    projects[7].place(city, currentCell);
  }

  currentCell.row = initialCell.row + 10;
  currentCell.column = initialCell.column + 2;

  if (projects[7].canPlace(city, currentCell)) {
    projects[7].place(city, currentCell);
  }

  currentCell.row = initialCell.row + 10;
  currentCell.column = initialCell.column + 4;

  if (projects[7].canPlace(city, currentCell)) {
    projects[7].place(city, currentCell);
  }

  currentCell.row = initialCell.row + 10;
  currentCell.column = initialCell.column + 6;

  if (projects[7].canPlace(city, currentCell)) {
    projects[7].place(city, currentCell);
  }

  currentCell.row = initialCell.row + 10;
  currentCell.column = initialCell.column + 8;

  if (projects[7].canPlace(city, currentCell)) {
    projects[7].place(city, currentCell);
  }

  currentCell.row = initialCell.row + 10;
  currentCell.column = initialCell.column + 10;

  if (projects[7].canPlace(city, currentCell)) {
    projects[7].place(city, currentCell);
  }
}

void placeDistricts(
  City city,
  List<Project> projects,
) {
  for (int row = 0; row < city.rows; row += 12) {
    for (int column = 0; column < city.columns; column += 12) {
      placeDistrict(
        city,
        new Cell(row, column),
        projects,
      );
    }
  }
}
