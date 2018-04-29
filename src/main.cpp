#include <bits/stdc++.h>

using namespace std;

long cityRows, cityCols, maxDistance, numOfBuildings;

char **cityMap;

struct buildingPlanType
{
    long x, y;
    long index;

    buildingPlanType(long a, long b, long c)
    {
        x = a;
        y = b;
        index = c;
    }
};

vector<buildingPlanType> buildingPlan;

struct buildingType
{
    char type;
    long height, width;
    long capacityOrType;
    long area;
    char **shape;
    long index;
    float eff = 0;

    buildingType(char a, long b, long c, long d, long e)
    {
        type = a;
        height = b;
        width = c;
        capacityOrType = d;
        index = e;
        area = height * width;

        if (type == 'R')
        {
            eff = (float)capacityOrType / area;
        }
        shape = new char *[height];

        for (long i = 0; i < height; ++i)
            shape[i] = new char[width];
    }

    bool canPlace(long x, long y)
    {
        if (x + height > cityRows || y + width > cityCols)
        {
            return false;
        }

        for (long i = 0; i < height; i++)
        {
            for (long j = 0; j < width; j++)
            {
                if (cityMap[x + i][y + j] != '.' && shape[i][j] == '#')
                {
                    return false;
                }
            }
        }

        return true;
    }

    void place(long x, long y)
    {
        buildingPlan.push_back(buildingPlanType(x, y, index));
        for (long i = 0; i < height; i++)
        {
            for (long j = 0; j < width; j++)
            {
                cityMap[x + i][y + j] = '#';
            }
        }
    }
};

struct bestResidential
{
    inline bool operator()(const buildingType &struct1, const buildingType &struct2)
    {
        return (struct1.eff > struct2.eff);
    }
};

struct bestUtility
{
    inline bool operator()(const buildingType &struct1, const buildingType &struct2)
    {
        return (struct1.area < struct2.area);
    }
};

cityCanFit(long x, long y)
{
}

vector<buildingType> buildings, residential, utility;

int main(int argc, char *argv[])
{
    double maxTime = 20;
    clock_t beginTime = clock();

    // Enable input from file
    if (argc > 1)
    {
        freopen(argv[1], "r", stdin);
    }

    // Enable output from file
    if (argc > 2)
    {
        freopen(argv[2], "w", stdout);
    }

    scanf("%ld %ld %ld %ld", &cityRows, &cityCols, &maxDistance, &numOfBuildings);

    cityMap = new char *[cityRows];
    for (long i = 0; i < cityRows; ++i)
    {
        cityMap[i] = new char[cityCols];
        memset(cityMap[i], '.', sizeof(char) * cityCols);
    }

    buildingType *newBuilding;

    // for reading
    char a;
    long b, c, d;

    for (long i = 0; i < numOfBuildings; i++)
    {
        a = 0;
        while (a != 'R' && a != 'U')
            scanf("%c", &a);

        scanf("%ld %ld %ld", &b, &c, &d);

        buildings.push_back(buildingType(a, b, c, d, i));
        if (a == 'R')
        {
            residential.push_back(buildings[i]);
        }
        else
        {
            utility.push_back(buildings[i]);
        }

        newBuilding = &buildings[i];

        for (long j = 0; j < newBuilding->height; j++)
        {
            scanf("%s", newBuilding->shape[j]);
        }
    }

    long rIndex = 0, uIndex = 0;
    long mostX = 0, mostY = 0;

    buildingType *currentBuilding;

    long inSize, outSize;

    long countHowManyR = 0, countHowManyU = 0;

    sort(residential.begin(), residential.end(), bestResidential());
    sort(utility.begin(), utility.end(), bestUtility());

    rIndex = 0;

    inSize = 0;
    outSize = 1;

    mostX = 0;
    mostY = 0;

    while (true)
    {
        currentBuilding = &residential[rIndex];

        while (!currentBuilding->canPlace(mostX, mostY))
        {
            mostY++;
            if (mostY == cityCols)
            {
                mostY = 0;
                mostX++;
            }

            if (mostX == cityRows)
            {
                break;
            }
        }

        if (currentBuilding->canPlace(mostX, mostY))
        {
            currentBuilding->place(mostX, mostY);

            mostY += currentBuilding->width + maxDistance + rand() % 2;

            if (mostY >= cityCols)
            {
                mostY = 0;
                mostX += currentBuilding->height + maxDistance + rand() % 2;
            }

            if (mostX >= cityRows)
            {
                break;
            }
        }
        else
        {
            break;
        }
    }

    while (inSize < outSize)
    {
        inSize = buildingPlan.size();

        for (int i = 0; i < utility.size(); i++)
        {
            currentBuilding = &utility[i];
            mostX = 0;
            mostY = 0;

            while (mostX < cityRows && mostY < cityCols)
            {
                while (!currentBuilding->canPlace(mostX, mostY))
                {
                    mostY++;
                    if (mostY == cityCols)
                    {
                        mostY = 0;
                        mostX++;
                    }

                    if (mostX == cityRows)
                    {
                        break;
                    }
                }
                if (currentBuilding->canPlace(mostX, mostY))
                {
                    currentBuilding->place(mostX, mostY);

                    mostY += currentBuilding->width + maxDistance * 2;

                    if (mostY >= cityCols)
                    {
                        mostY = 0;
                        mostX += currentBuilding->height + maxDistance * 2;
                    }

                    if (mostX >= cityRows)
                    {
                        break;
                    }
                }
                else
                {
                    break;
                }
            }
        }
        if (double(clock() - beginTime) / CLOCKS_PER_SEC > maxTime)
        {
            break;
        }

        outSize = buildingPlan.size();
        rIndex++;
    }

    while (inSize < outSize)
    {
        inSize = buildingPlan.size();

        for (int i = 0; i < residential.size(); i++)
        {
            currentBuilding = &residential[i];
            mostX = 0;
            mostY = 0;

            while (mostX < cityRows && mostY < cityCols)
            {
                while (!currentBuilding->canPlace(mostX, mostY))
                {
                    mostY++;
                    if (mostY == cityCols)
                    {
                        mostY = 0;
                        mostX++;
                    }

                    if (mostX == cityRows)
                    {
                        break;
                    }
                }
                if (currentBuilding->canPlace(mostX, mostY))
                {
                    currentBuilding->place(mostX, mostY);

                    mostY += currentBuilding->width;

                    if (mostY >= cityCols)
                    {
                        mostY = 0;
                        mostX += currentBuilding->height;
                    }

                    if (mostX >= cityRows)
                    {
                        break;
                    }
                }
                else
                {
                    break;
                }
            }
        }
        if (double(clock() - beginTime) / CLOCKS_PER_SEC > maxTime)
        {
            break;
        }

        outSize = buildingPlan.size();
        rIndex++;
    }

    mostX = 0;
    mostY = 0;

    while (true)
    {
        currentBuilding = &residential[1];

        while (!currentBuilding->canPlace(mostX, mostY))
        {
            mostY++;
            if (mostY == cityCols)
            {
                mostY = 0;
                mostX++;
            }

            if (mostX == cityRows)
            {
                break;
            }
        }

        if (currentBuilding->canPlace(mostX, mostY))
        {
            currentBuilding->place(mostX, mostY);

            mostY += 1;

            if (mostY >= cityCols)
            {
                mostY = 0;
                mostX += 1;
            }

            if (mostX >= cityRows)
            {
                break;
            }
        }
        else
        {
            break;
        }
    }

    mostX = 0;
    mostY = 0;

    while (true)
    {
        currentBuilding = &residential[2];

        while (!currentBuilding->canPlace(mostX, mostY))
        {
            mostY++;
            if (mostY == cityCols)
            {
                mostY = 0;
                mostX++;
            }

            if (mostX == cityRows)
            {
                break;
            }
        }

        if (currentBuilding->canPlace(mostX, mostY))
        {
            currentBuilding->place(mostX, mostY);

            mostY += 1;

            if (mostY >= cityCols)
            {
                mostY = 0;
                mostX += 1;
            }

            if (mostX >= cityRows)
            {
                break;
            }
        }
        else
        {
            break;
        }
    }

    mostX = 0;
    mostY = 0;

    while (true)
    {
        currentBuilding = &residential[3];

        while (!currentBuilding->canPlace(mostX, mostY))
        {
            mostY++;
            if (mostY == cityCols)
            {
                mostY = 0;
                mostX++;
            }

            if (mostX == cityRows)
            {
                break;
            }
        }

        if (currentBuilding->canPlace(mostX, mostY))
        {
            currentBuilding->place(mostX, mostY);

            mostY += 1;

            if (mostY >= cityCols)
            {
                mostY = 0;
                mostX += 1;
            }

            if (mostX >= cityRows)
            {
                break;
            }
        }
        else
        {
            break;
        }
    }

    printf("%ld\n", buildingPlan.size());
    for (long i = 0; i < buildingPlan.size(); i++)
    {
        printf("%ld %ld %ld\n", buildingPlan[i].index, buildingPlan[i].x, buildingPlan[i].y);
    }
    /*
    for (long j = 0; j < cityRows; j++) {
        printf ("%s\n", cityMap[j]);
    }
    printf ("\n");

    for (long i = 0; i < numOfBuildings; i++) {
        for (long j = 0; j < buildings[i].height; j++) {
            printf ("%s\n", buildings[i].shape[j]);
        }
        printf ("\n");
    }

    */
    return 0;
}