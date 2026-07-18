#include <iostream>
#include <map>
#include <string>
#include <stdio.h>
// #include "wifi/wifi_api.h"
// #include "Windows.h"
// 基础日志宏
#define log(format, ...) printf(format, ##__VA_ARGS__)

// extern void add();
int main() 
{
    // wifi_init();
    // add();
    // log("Hello, my_incremental_build.sh !\n");   
    // CreateFile
    // system("CD");
    // log("Hello, 1~\n"); 
    // log("Hello, 2~\n"); 
    // log("Hello, 3~\n");   
    // log("Hello, 4~\n");   
    // log("Hello, 5~\n");   
    // log("Hello, 6~\n");   
    // log("Hello, 7~\n");   
    // log("Hello, 8~\n");
    // log("Hello, 9~\n");
    log("Hello, %s!\n", "World");
    log("Hello, %s!\n", "Vscode");   
    log("Hello, %s!\n", "Shell");   
    log("Hello, %s!\n", "Cmake");   
    log("Hello, %s!\n", "C/C++");   
    getchar();
    return 0;
}