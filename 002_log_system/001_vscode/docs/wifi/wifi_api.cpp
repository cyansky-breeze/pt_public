#include "wifi_api.h"
#include <iostream>
#include <stdio.h>
// 基础日志宏
#define wifi_log(format, ...) printf(format, ##__VA_ARGS__)
int wifi_init() 
{
    wifi_log("wifi init successfully~\n");
    return 0;
}