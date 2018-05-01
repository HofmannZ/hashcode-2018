

#include <bits/stdc++.h>

using namespace std;

long cityRows, cityCols, maxDistance, numOfBuildings;

long** cityMap;

const long UTILITY_TYPES = 1000;

struct utilityBlock {
    bool* _utilityBinary;
    long maxSize = 0;

    utilityBlock() {
        _utilityBinary = new bool[UTILITY_TYPES + 1];

        memset(_utilityBinary, false, sizeof(bool) * (UTILITY_TYPES + 1));
    };

    void setUtility(long &index, bool value = true) {
        maxSize = max(maxSize, index);
        _utilityBinary[index] = value;
    }

    bool getUtilityValue(long &index) {
        return _utilityBinary[index];
    }

    long countUtilities() {
        int result = 0;
        for (int i = 0; i <= maxSize; i++)
            if (_utilityBinary[i])
                result++;

        return result;
    }

    utilityBlock* operator+(utilityBlock& b) {
        utilityBlock* result = new utilityBlock();

        int maxSize = max(this->maxSize, b.maxSize);

        for (long i = 0; i <= maxSize; i++)
            result->setUtility(i, (this->getUtilityValue(i) | b.getUtilityValue(i)));

        return (result);
    }
};

struct buildingPlanType {
    long x, y;
    long index = 0;

    buildingPlanType(long a, long b, long c) {
        x = a;
        y = b;
        index = c;
    }
};

vector<buildingPlanType> buildingPlan;

struct buildingType {
    char type;
    long height, width;
    long capacityOrType;
    long area;
    char** shape;
    long index;
    float eff = 0;

    buildingType(char a, long b, long c, long d, long e) {
        type = a;
        height = b;
        width = c;
        capacityOrType = d;
        index = e;
        area = height * width;

        if (type == 'R') {
            eff = (float)capacityOrType / area;
        }
        shape = new char*[height];

        for (long i = 0; i < height; ++i)
            shape[i] = new char[width];
    }

    bool canPlace(long x, long y) {
        if (x + height > cityRows || y + width > cityCols) {
            return false;
        }

        for (long i = 0; i < height; i++) {
            for (long j = 0; j < width; j++) {
                if (cityMap[x + i][y + j] != '-2' && shape[i][j] == '#') {
                    return false;
                }
            }
        }

        return true;
    }

    void place(long x, long y) {
        buildingPlan.push_back(buildingPlanType(x, y, index));
        for (long i = 0; i < height; i++) {
            for (long j = 0; j < width; j++) {
                if (type == 'R')
                    cityMap[x + i][y + j] = -1;
                else
                    cityMap[x + i][y + j] = capacityOrType;
            }
        }
    }

    long calculateScore(int startingX, int startingY) {
        utilityBlock* utilitiesAround = new utilityBlock();
        int around[4];

        for (int i = 0; i < height; i++) {
            for (int j = 0; j < width; j++) {
                if (shape[i][j] == '#') {
                    around[0] = (i > 0 && shape[i - 1][j] == '#') ? 0 : 1;
                    around[1] = (i + 1 < height && shape[i + 1][j] == '#') ? 0 : 1;
                    around[2] = (j > 0 && shape[i][j - 1] == '#') ? 0 : 1;
                    around[3] = (j + 1 < width && shape[i][j + 1] == '#') ? 0 : 1;

                calculateScorePerPoint(i + startingX, j + startingY, *utilitiesAround, around);
                }
            }
        }

        return utilitiesAround->countUtilities();
    }

    void calculateScorePerPoint(int x, int y, utilityBlock& neighbours, int around[4]) {
        int minX = around[0] ? (x - maxDistance) : x;
        int maxX = around[1] ? (x + maxDistance) : x;
        int minY = around[2] ? (y - maxDistance) : y;
        int maxY = around[3] ? (y + maxDistance) : y;
        int distance = 0;

        //utilityBlock* utilitiesAround = new utilityBlock();

        for (int newX = minX; newX <= maxX; newX++) {
            for (int newY = minY; newY <= maxY; newY++) {
                distance = abs(newX - x) + abs(newY - y);

                if (distance <= maxDistance)
                    if (newX >= 0 && newX < cityRows && newY >= 0 && newY < cityCols && cityMap[newX][newY] >= 0)
                        neighbours.setUtility(cityMap[newX][newY]);
            }
        }
    }
};

struct bestResidential
{
    inline bool operator() (const buildingType& struct1, const buildingType& struct2)
    {
        return (struct1.eff > struct2.eff);
    }
};

struct bestUtility
{
    inline bool operator() (const buildingType& struct1, const buildingType& struct2)
    {
        return (struct1.area < struct2.area);
    }
};

vector <buildingType> buildings, residential, utility, uniqueUtility;

bool uniqueUtilityArray[10001];

int main(int argc, char* argv[])
{
    double maxTime = 5;
    clock_t beginTime = clock();

    // Enable input from file
    if (argc > 1) {
        freopen (argv[1], "r", stdin);
    }

    scanf ("%ld %ld %ld %ld", &cityRows, &cityCols, &maxDistance, &numOfBuildings);


    cityMap = new long*[cityRows];
        for (long i = 0; i < cityRows; ++i) {
            cityMap[i] = new long[cityCols];
            memset( cityMap[i], -2, sizeof(long)*cityCols );
        }

    buildingType* newBuilding;

    // for reading
    char a;
    long b, c, d;

    for (long i = 0; i < numOfBuildings; i++) {
        a = 0;
        while(a != 'R' && a != 'U')
            scanf("%c", &a);

        scanf ("%ld %ld %ld", &b, &c, &d);

        buildings.push_back(buildingType(a, b, c, d, i));
        if (a == 'R') {
            residential.push_back(buildings[i]);
        } else {
            utility.push_back(buildings[i]);
        }

        newBuilding = &buildings[i];

        for (long j = 0; j < newBuilding->height; j++) {
            scanf("%s", newBuilding->shape[j]);
        }
    }

    // Read input

    if (argc > 2) {
        freopen (argv[2], "r", stdin);
    }

    // Read output

    long numOfProjects;
    long buildingId, xCoord, yCoord;
    scanf ("%ld", &numOfProjects);


    for (int i = 0; i < numOfProjects; i++) {
        scanf("%ld %ld %ld", &buildingId, &xCoord, &yCoord);
        buildings[buildingId].place(xCoord, yCoord);
    }

    long totalScore, score, index;
    totalScore = 0;

    for (int i = 0; i < numOfProjects; i++) {
        index = buildingPlan[i].index;

        if(buildings[index].type == 'U') {
            continue;
        }
        score = buildings[index].calculateScore(buildingPlan[i].x, buildingPlan[i].y);
        totalScore += score * buildings[index].capacityOrType;
    }

    cout << totalScore;
}

