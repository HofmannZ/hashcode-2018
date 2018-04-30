import 'dart:io';
import 'dart:convert';
import 'dart:async';

import 'package:args/args.dart';

int cityRows;
int cityColumns;
int maximumWalkingDistance;
int nBuildingPlans;

List<Project> projects;
List<List<int>> cityMap = new List();
List<List<int>> constructedBuildings = new List();

class Cell {
  int row, column;

  // I ❤️ Dart for this
  Cell(this.row, this.column);
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

  bool canPlace(Cell cell) {
    // is outside of the city map
    if (cell.column + this.width > cityColumns ||
        cell.row + this.height > cityRows) {
      return false;
    }

    // check all occupid cells
    for (int i = 0; i < this.occupidCells.length; i++) {
      if (cityMap[cell.row + this.occupidCells[i].row]
              [cell.column + this.occupidCells[i].column] !=
          -1) {
        return false;
      }
    }

    return true;
  }

  void place(Cell cell) {
    constructedBuildings.add([this.index, cell.row, cell.column]);

    for (int i = 0; i < this.occupidCells.length; i++) {
      cityMap[this.occupidCells[i].row + cell.row]
          [this.occupidCells[i].column + cell.column] = this.index;

      // pintDebug();
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

  await parseInput(inputLines);

  // divide the pojects in two lists
  List<Project> residentialProjects = getResidentialProjects();
  List<Project> utilityProjects = getUtilityProjects();

  // sort both lits based on their efficiency
  sortProject(residentialProjects);
  sortProject(utilityProjects);

  // remove less efficient utility project types that are already in included
  List<Project> uniqueUtilityProjects =
      getUniqueUtilityProjects(utilityProjects);

  // place only the most efficient residential project
  placeResidentialProjects(residentialProjects, 0);

  // place the most efficient utility projects or their service
  for (int i = 0; i < 1024; i++) {
    placeUtilityProjects(uniqueUtilityProjects);
  }

  // re-iterate with the top 10% less efficient utility projects
  for (int i = 0; i < utilityProjects.length / 10; i++) {
    placeUtilityProjects(
      utilityProjects,
      currentUtilityProject: i,
      placeUnique: false,
    );
  }

  // re-iterate with the top 10% less efficient projects that might fit in the free space
  for (int i = 1; i < residentialProjects.length / 10; i++) {
    placeResidentialProjects(residentialProjects, i, spaced: false);
  }

  IOSink outputSink = new File(argResults['output']).openWrite();

  await printOutput(outputSink);

  // close streams
  outputSink.close();
}

Future parseInput(Stream inputLines) async {
  int lineIndex = 0;
  int nextParsingProject = 0;
  int lineInParsingProject = 0;

  try {
    await for (String line in inputLines) {
      List<String> lineItems = line.split(' ');

      if (lineIndex == 0) {
        cityRows = int.parse(lineItems[0]);
        cityColumns = int.parse(lineItems[1]);
        maximumWalkingDistance = int.parse(lineItems[2]);
        nBuildingPlans = int.parse(lineItems[3]);

        projects = new List(nBuildingPlans);

        for (int row = 0; row < cityRows; row++) {
          cityMap.add(new List());

          for (int column = 0; column < cityColumns; column++) {
            cityMap[row].add(-1);
          }
        }
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
          currentProject.parseAndAddRowOfCells(lineInParsingProject - 1, line);

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
}

Future printOutput(IOSink outputSink) async {
  await outputSink.writeln(constructedBuildings.length);

  for (int i = 0; i < constructedBuildings.length; i++) {
    await outputSink.write(constructedBuildings[i][0]);
    await outputSink.write(' ');
    await outputSink.write(constructedBuildings[i][1]);
    await outputSink.write(' ');
    await outputSink.write(constructedBuildings[i][2]);
    await outputSink.write('\n');
  }
}

void pintDebug() {
  print('City map:');

  for (int i = 0; i < cityRows; i++) {
    print(cityMap[i]);
  }

  print('');
}

List<Project> getResidentialProjects() {
  List<Project> residentialProjects = new List.from(projects);
  residentialProjects.retainWhere((Project project) => project.type == 'R');

  return residentialProjects;
}

List<Project> getUtilityProjects() {
  List<Project> utilityProjects = new List.from(projects);
  utilityProjects.retainWhere((Project project) => project.type == 'U');

  return utilityProjects;
}

void sortProject(List<Project> project) {
  project.sort((a, b) => b.efficiency.compareTo(a.efficiency));
}

List<Project> getUniqueUtilityProjects(List<Project> utilityProjects) {
  List<Project> uniqueUtilityProjects = new List();

  bool hasMoreUnique = true;
  int currentUtillity = 1;

  while (hasMoreUnique) {
    Project uniqueUtilityProject = utilityProjects.firstWhere((project) {
      if (project.type != 'U') {
        return false;
      }

      if (project.capacityOrService == currentUtillity) {
        return true;
      }

      return false;
    }, orElse: () => new Project(-1, 'U', 0, 0, 0));

    if (uniqueUtilityProject.index != -1) {
      uniqueUtilityProjects.add(uniqueUtilityProject);
      currentUtillity++;
    } else {
      hasMoreUnique = false;
    }
  }

  return uniqueUtilityProjects;
}

void placeResidentialProjects(
  List<Project> residentialProjects,
  int currentResidentialProject, {
  bool spaced: true,
}) {
  for (int row = 0; row < cityRows; row++) {
    for (int column = 0; column < cityColumns; column++) {
      Cell cell = new Cell(row, column);

      if (residentialProjects[currentResidentialProject].canPlace(cell)) {
        residentialProjects[currentResidentialProject].place(cell);

        if (spaced) {
          // add horizontal distance between two residential projects
          column += maximumWalkingDistance;

          // add vertical distance between two residential projects
          if (column + residentialProjects[currentResidentialProject].width >=
              cityColumns) {
            row += maximumWalkingDistance;
          }
        }
      }
    }
  }
}

void placeUtilityProjects(
  List<Project> utilityProjects, {
  int currentUtilityProject: 0,
  bool placeUnique: true,
}) {
  for (int row = 0; row < cityRows; row++) {
    for (int column = 0; column < cityColumns; column++) {
      Cell cell = new Cell(row, column);

      if (utilityProjects[currentUtilityProject].canPlace(cell)) {
        utilityProjects[currentUtilityProject].place(cell);

        if (placeUnique) {
          currentUtilityProject++;
        }
      }

      if (currentUtilityProject >= utilityProjects.length) {
        currentUtilityProject = 0;
      }
    }
  }
}
