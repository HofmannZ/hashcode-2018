import 'dart:io';
import 'dart:convert';
import 'dart:async';

import 'package:args/args.dart';

int rows;
int columns;
int maximumWalkingDistance;
int nBuildingPlans;

List<Project> projects;

class Project {
  int height, width;
  List<List<int>> occupidCells;

  // I ❤️ Dart for this
  Project(this.height, this.width);

  void parseAndAddRowOfCells(int rowIndex, String rawRow) {
    for (int i; i < rawRow.length; i++) {
      if (rawRow[i] == '#') {
        List<int> cell = [i, rowIndex];
        occupidCells.add(cell);
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

  IOSink outputSink = new File(argResults['output']).openWrite();

  // close streams
  outputSink.close();
}

Future parseInput(Stream inputLines) async {
  int lineIndex = 0;
  int lineOfParsingProject = 0;

  try {
    await for (String line in inputLines) {
      List<String> lineItems = line.split(' ');

      if (lineIndex == 0) {
        rows = int.parse(lineItems[0]);
        columns = int.parse(lineItems[1]);
        maximumWalkingDistance = int.parse(lineItems[2]);
        nBuildingPlans = int.parse(lineItems[3]);
      } else {
        if (lineOfParsingProject == 0) {
          // int type = lineItems[0];
          int height = int.parse(lineItems[1]);
          int width = int.parse(lineItems[2]);
          // int capacityOrType = int.parse(lineItems[3]);

          projects.add(new Project(height, width));
        } else {
          Project currentProject = projects.last;
          currentProject.parseAndAddRowOfCells(lineOfParsingProject - 1, line);

          // reset the parsing line
          if (lineOfParsingProject == currentProject.height) {
            lineOfParsingProject = 0;
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
