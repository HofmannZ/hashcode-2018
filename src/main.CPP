#include <bits/stdc++.h>

using namespace std;

int main(int argc, char *argv[])
{
    char *fileInName;
    fileInName = getenv("INPUT_FILE");

    char *fileOutName;
    fileOutName = getenv("OUTPUT_FILE");

    freopen(fileInName, "r", stdin);
    freopen(fileOutName, "w", stdout);

    char x;
    cin >> x;
    cout << x;

    return 0;
}