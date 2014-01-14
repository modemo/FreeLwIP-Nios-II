#include <stdio.h>
#include <FreeRTOS.h>
#include <task.h>

/* Definition of Task Stacks */
#define TASK_STACKSIZE      1024

/* Definition of Task Priorities */
#define TASK1_PRIORITY      1
#define TASK2_PRIORITY      2

/* Stack overflow hook */
void vApplicationStackOverflowHook( xTaskHandle xTask, signed char *pcTaskName )
{
  while (1);
}

/* Prints "Hello World" and sleeps for three seconds */
void vTask1( void *pvParameters )
{
  while (1)
  { 
    printf("Hello from task 1\n");
    vTaskDelay(3000/portTICK_RATE_MS);
  }
}
/* Prints "Hello World" and sleeps for three seconds */
void vTask2( void *pvParameters )
{
  while (1)
  { 
    printf("Hello from task 2\n");
    vTaskDelay(3000/portTICK_RATE_MS);
  }
}
/* The main function creates two task and starts multi-tasking */
int main(void)
{
  xTaskCreate(vTask1,
              "Task 1",
              TASK_STACKSIZE,
              NULL,
              TASK1_PRIORITY,
              NULL);
  
  xTaskCreate(vTask2,
              "Task 2",
              TASK_STACKSIZE,
              NULL,
              TASK2_PRIORITY,
              NULL);            
               
  vTaskStartScheduler();
  return 0;
}
