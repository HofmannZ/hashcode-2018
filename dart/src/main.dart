import 'dart:io';
import 'dart:convert';
import 'dart:async';

import 'package:args/args.dart';

int cityRows;
int cityColumns;
int maximumWalkingDistance;
int nBuildingPlans;

List<Project> projects;

List<List<int>> cityMap;

class Project {
  String type;
  int index, height, width, capacityOrService, surface;
  double efficiency;
  List<List<int>> occupidCells = new List();

  // I ❤️ Dart for this
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

  void parseAndAddRowOfCells(int rowIndex, String rawRow) {
    for (int i = 0; i < rawRow.length; i++) {
      if (rawRow[i] == '#') {
        List<int> cell = [i, rowIndex];
        occupidCells.add(cell);
      }
    }
  }

  bool canPlace(int x, int y) {
    // is outside of the city
    if (x + this.height > cityRows || y + this.width > cityColumns) {
      return false;
    }

    // check all cells
    for (int i = 0; i < this.height; i++) {
      for (int j = 0; j < this.width; j++) {
        if (cityMap[x + i][y + j] != '.' && this.occupidCells[i][j] == '#') {
          return false;
        }
      }
    }

    return true;
  }

  void place(int x, int y) {
    for (int i = 0; i < height; i++) {
      for (int j = 0; j < width; j++) {
        cityMap[x + i][y + j] = this.index;
      }
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

  for (int i = 0; i < utilityProjects.length; i++) {
    stdout.writeln(utilityProjects[i].type);
    stdout.writeln(utilityProjects[i].height);
    stdout.writeln(utilityProjects[i].width);
    stdout.writeln(utilityProjects[i].capacityOrService);
    stdout.writeln(utilityProjects[i].surface);
    stdout.writeln(utilityProjects[i].efficiency);
    for (int j = 0; j < utilityProjects[i].occupidCells.length; j++) {
      stdout.writeln(utilityProjects[i].occupidCells[j][0].toString() +
          ',' +
          utilityProjects[i].occupidCells[j][1].toString());
    }
    stdout.write('\n');
  }

  for (int i = 0; i < residentialProjects.length; i++) {
    stdout.writeln(residentialProjects[i].type);
    stdout.writeln(residentialProjects[i].height);
    stdout.writeln(residentialProjects[i].width);
    stdout.writeln(residentialProjects[i].capacityOrService);
    stdout.writeln(residentialProjects[i].surface);
    stdout.writeln(residentialProjects[i].efficiency);
    for (int j = 0; j < residentialProjects[i].occupidCells.length; j++) {
      stdout.writeln(residentialProjects[i].occupidCells[j][0].toString() +
          ',' +
          residentialProjects[i].occupidCells[j][1].toString());
    }
    stdout.write('\n');
  }

  IOSink outputSink = new File(argResults['output']).openWrite();

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
        cityMap = new List.filled(cityRows, new List.filled(cityColumns, 0));
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
  project.sort((a, b) => a.efficiency.compareTo(b.efficiency));
}
