#include <bits/stdc++.h>

using namespace std;

int main(int argc, char *argv[])
{
    char *fileInName;
    fileInName = getenv("INPUT_FILE");

    char *fileOutName;
    fileOutName = getenv("OUTPUT_FILE");

    if (argc > 1)
    {
        freopen(argv[2], "r", stdin);
    }

    if (argc > 2)
    {
        freopen(argv[3], "w", stdout);
    }

    char x;
    cin >> x;
    cout << x;

    return 0;
}