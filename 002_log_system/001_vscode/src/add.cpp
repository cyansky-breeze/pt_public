#include <iostream>
#include <map>
#include <string>
#include <stdio.h>
// #include "wifi/wifi_api.h"
// 基础日志宏
#define log(format, ...) printf(format, ##__VA_ARGS__)

void add()
{
    int a = 520;
    int b = 250;
    log("a+b=%d\n",a+b);
}