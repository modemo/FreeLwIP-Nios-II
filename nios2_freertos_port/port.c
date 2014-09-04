/*
    FreeRTOS V8.1.2 - Copyright (C) 2014 Real Time Engineers Ltd.

    VISIT http://www.FreeRTOS.org TO ENSURE YOU ARE USING THE LATEST VERSION.

    ***************************************************************************
     *                                                                       *
     *    FreeRTOS provides completely free yet professionally developed,    *
     *    robust, strictly quality controlled, supported, and cross          *
     *    platform software that has become a de facto standard.             *
     *                                                                       *
     *    Help yourself get started quickly and support the FreeRTOS         *
     *    project by purchasing a FreeRTOS tutorial book, reference          *
     *    manual, or both from: http://www.FreeRTOS.org/Documentation        *
     *                                                                       *
     *    Thank you!                                                         *
     *                                                                       *
    ***************************************************************************






    This file is part of the FreeRTOS distribution.

    FreeRTOS is free software; you can redistribute it and/or modify it under
    the terms of the GNU General Public License (version 2) as published by the
    Free Software Foundation >>!AND MODIFIED BY!<< the FreeRTOS exception.

    >>! NOTE: The modification to the GPL is included to allow you to distribute
    >>! a combined work that includes FreeRTOS without being obliged to provide
    >>! the source code for proprietary components outside of the FreeRTOS
    >>! kernel.

    FreeRTOS is distributed in the hope that it will be useful, but WITHOUT ANY
    WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
    FOR A PARTICULAR PURPOSE.  Full license text is available from the following
    link: http://www.freertos.org/a00114.html


    1 tab == 4 spaces!

    ***************************************************************************
     *                                                                       *
     *    Having a problem?  Start by reading the FAQ "My application does   *
     *    not run, what could be wrong?"                                     *
     *                                                                       *
     *    http://www.FreeRTOS.org/FAQHelp.html                               *
     *                                                                       *
    ***************************************************************************

    http://www.FreeRTOS.org - Documentation, books, training, latest versions,
    license and Real Time Engineers Ltd. contact details.

    http://www.FreeRTOS.org/plus - A selection of FreeRTOS ecosystem products,
    including FreeRTOS+Trace - an indispensable productivity tool, a DOS
    compatible FAT file system, and our tiny thread aware UDP/IP stack.

    http://www.OpenRTOS.com - Real Time Engineers ltd license FreeRTOS to High
    Integrity Systems to sell under the OpenRTOS brand.  Low cost OpenRTOS
    licenses offer ticketed support, indemnification and middleware.

    http://www.SafeRTOS.com - High Integrity Systems also provide a safety
    engineered and independently SIL3 certified version for use in safety and
    mission critical applications that require provable dependability.

    1 tab == 4 spaces!
*/

/*-----------------------------------------------------------
 * Implementation of functions defined in portable.h for the NIOS2 port.
 *----------------------------------------------------------*/

/* Standard Includes. */
#include <string.h>
#include <errno.h>

/* Altera includes. */
#include "sys/alt_irq.h"
#include "altera_avalon_timer_regs.h"
#include "priv/alt_irq_table.h"
#include "priv/alt_legacy_irq.h"

/* Scheduler includes. */
#include "FreeRTOS.h"
#include "projdefs.h"
#include "task.h"

/* Interrupts are enabled. */
#define portINITIAL_ESTATUS     ( StackType_t ) 0x01 

/*-----------------------------------------------------------*/

static inline void prvReadGp( unsigned long *ulValue )
{
	asm volatile ( "stw gp, (%0)" : : "r"(ulValue) );
}
/*-----------------------------------------------------------*/

/* 
 * See header file for description. 
 */
StackType_t *pxPortInitialiseStack( StackType_t *pxTopOfStack, TaskFunction_t pxCode, void *pvParameters )
{    
StackType_t *pxFramePointer = pxTopOfStack - 1;
StackType_t xGlobalPointer;

    prvReadGp( &xGlobalPointer ); 

    /* End of stack marker. */
    *pxTopOfStack = 0xdeadbeef;
    pxTopOfStack--;

    *pxTopOfStack = ( StackType_t ) pxFramePointer;
    pxTopOfStack--;
    
    *pxTopOfStack = xGlobalPointer; 
    
    /* Space for R23 to R16. */
    pxTopOfStack -= 9;

    *pxTopOfStack = ( StackType_t ) pxCode;
    pxTopOfStack--;

    *pxTopOfStack = portINITIAL_ESTATUS;

    /* Space for R15 to R5. */
    pxTopOfStack -= 12;

    *pxTopOfStack = ( StackType_t ) pvParameters;

    /* Space for R3 to R1, muldiv and RA. */
    pxTopOfStack -= 5;

    return pxTopOfStack;
}
/*-----------------------------------------------------------*/

/* 
 * See header file for description. 
 */
BaseType_t xPortStartScheduler( void )
{	
	/* Start the first task. */
    asm volatile (  " movia r2, restore_sp_from_pxCurrentTCB        \n"
                    " jmp r2                                          " );

	/* Should not get here! */
	return 0;
}
/*-----------------------------------------------------------*/

void vPortEndScheduler( void )
{
	/* It is unlikely that the NIOS2 port will require this function as there
	is nothing to return to.  */
}
/*-----------------------------------------------------------*/

void vPortSysTickHandler( void )
{
    // Only make ticks if the scheduler has been started.
    if ( xTaskGetSchedulerState() != taskSCHEDULER_NOT_STARTED )
    {
        /* Increment the kernel tick. */
        if( xTaskIncrementTick() != pdFALSE )
        {
            vTaskSwitchContext();
        }
     }
}
/*-----------------------------------------------------------*/

static volatile alt_irq_context lastContext;
static volatile int irqDisableCount;

void fixed_alt_irq_disable_all()
{
    alt_irq_context ctxt = alt_irq_disable_all();
    lastContext |= ctxt;
    ++irqDisableCount;
}

void fixed_alt_irq_enable_all()
{
    if (--irqDisableCount == 0)
    {
        alt_irq_enable_all(lastContext);
        lastContext = 0;
    }
}
