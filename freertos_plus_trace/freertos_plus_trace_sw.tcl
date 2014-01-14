#
# freertos_plus_trace_sw.tcl -- A description of FreeRTOS+ Trace for
#                               Altera Nios II BSP tools
#

# Create a new software package "FreeRTOS-Plus-Trace"
create_sw_package freertos_plus_trace

# The version of this software
set_sw_property version 2.5.0

# (Don't) initialize the driver in alt_sys_init()
set_sw_property auto_initialize false

# Location in generated BSP that above sources will be copied into
# Suggestion: Keep this the same (case and all) as that where the OS
# source files came from. The Nios II FreeRTOS distribution had this
# as a root-directory name for the sources.
set_sw_property bsp_subdirectory FreeRTOS-Plus-Trace
  
#
# Source file listings...
#

# C source files
add_sw_property c_source FreeRTOS/src/trcBase.c
add_sw_property c_source FreeRTOS/src/trcHardwarePort.c
add_sw_property c_source FreeRTOS/src/trcKernel.c
add_sw_property c_source FreeRTOS/src/trcKernelPort.c
add_sw_property c_source FreeRTOS/src/trcUser.c

# Include files
add_sw_property include_source FreeRTOS/inc/trcBase.h
add_sw_property include_source FreeRTOS/inc/trcConfig.h
add_sw_property include_source FreeRTOS/inc/trcHardwarePort.h
add_sw_property include_source FreeRTOS/inc/trcKernel.h
add_sw_property include_source FreeRTOS/inc/trcKernelHooks.h
add_sw_property include_source FreeRTOS/inc/trcKernelPort.h
add_sw_property include_source FreeRTOS/inc/trcTypes.h
add_sw_property include_source FreeRTOS/inc/trcUser.h

# Include paths
add_sw_property include_directory inc

# This driver supports only FreeRTOS BSP (OS) type
add_sw_property supported_bsp_type FreeRTOS

# Makefile additions
add_sw_property alt_cppflags_addition "-D__freertos_plus_trace__"

#
# FreeRTOS+ Trace Settings
#
add_sw_setting decimal_number system_h_define event_buffer_size OS_TRACE_EVENT_BUFFER_SIZE 1000 "Define the capacity of the event buffer."

add_sw_setting boolean system_h_define use_linker_pragma OS_TRACE_USE_LINKER_PRAGMA 0 "If this is 1, the header file recorderdata_linker_pragma.h is included just before the declaration of RecorderData (in trcBase.c)."

add_sw_setting decimal_number system_h_define symbol_table_size OS_TRACE_SYMBOL_TABLE_SIZE 1000 "Define the capacity of the symbol table, in bytes."

add_sw_setting boolean system_h_define use_separate_user_event_buffer OS_TRACE_USE_SEPARATE_USER_EVENT_BUFFER 0 "Enable or disable the use of the separate user event buffer."

add_sw_setting decimal_number system_h_define user_event_buffer_size OS_TRACE_USER_EVENT_BUFFER_SIZE 500 "Define the capacity of the user event buffer, in number of slots."

add_sw_setting decimal_number system_h_define channel_format_pairs OS_TRACE_CHANNEL_FORMAT_PAIRS 32 ""

add_sw_setting decimal_number system_h_define n_task OS_TRACE_NTask 32 ""

add_sw_setting decimal_number system_h_define n_isr OS_TRACE_NISR 100 ""

add_sw_setting decimal_number system_h_define n_queue OS_TRACE_NQueue 12 ""

add_sw_setting decimal_number system_h_define n_semaphore OS_TRACE_NSemaphore 12 ""

add_sw_setting decimal_number system_h_define n_mutex OS_TRACE_NMutex 10 ""

add_sw_setting decimal_number system_h_define name_len_isr OS_TRACE_NameLenISR 15 ""

add_sw_setting decimal_number system_h_define name_len_queue OS_TRACE_NameLenQueue 15 ""

add_sw_setting decimal_number system_h_define name_len_semaphore OS_TRACE_NameLenSemaphore 15 ""

add_sw_setting decimal_number system_h_define name_len_mutex OS_TRACE_NameLenMutex 15 ""

add_sw_setting quoted_string system_h_define trace_description OS_TRACE_DESCRIPTION "Traceanalyzer Recorder" "String displayed in Traceanalyzer"

add_sw_setting decimal_number system_h_define trace_description_max_length OS_TRACE_DESCRIPTION_MAX_LENGTH 80 "The maximum length (including zero termination) for the TRACE_DESCRIPTION string."

add_sw_setting boolean_define_only system_h_define trace_data_allocation_dynamic OS_TRACE_DATA_ALLOCATION_DYNAMIC 0 "Using static allocation has the benefits of compile-time errors if the buffer is too large (too large constants in trcConfig.h) and no need to call the initialization routine (xTraceInitTraceData)."

add_sw_setting boolean system_h_define use_trace_assert OS_TRACE_USE_TRACE_ASSERT 1 "If this is one (1), the TRACE_ASSERT macro will verify that a condition is true. If the condition is false, vTraceError() will be called."

add_sw_setting boolean system_h_define include_float_support OS_TRACE_INCLUDE_FLOAT_SUPPORT 1 "If this is zero (0), all references to floating point values are removed, in case floating point values are not supported by the platform used."

add_sw_setting boolean system_h_define include_user_events OS_TRACE_INCLUDE_USER_EVENTS 1 "If this is zero (0) the code for creating User Events is excluded to reduce code size"

add_sw_setting boolean system_h_define include_ready_events OS_TRACE_INCLUDE_READY_EVENTS 1 "If this is zero (0), the code for recording Ready events is excluded."

add_sw_setting boolean system_h_define include_new_time_events OS_TRACE_INCLUDE_NEW_TIME_EVENTS 0 "If this is zero (1), events will be generated whenever the os clock is increased."

add_sw_setting boolean system_h_define include_isr_tracing OS_TRACE_INCLUDE_ISR_TRACING 1 "If this is zero (0), the code for recording Interrupt Service Routines is excluded to reduce code size."

add_sw_setting boolean system_h_define include_object_delete OS_TRACE_INCLUDE_OBJECT_DELETE 1 "This must be enabled (1) if tasks, queues or other traced kernel objects are deleted at runtime."

add_sw_setting boolean_define_only system_h_define trace_store_mode_ring_buffer OS_TRACE_STORE_MODE_RING_BUFFER 0 "If this is zero (0), the recording is stopped when the buffer becomes full."

add_sw_setting decimal_number system_h_define stop_after_n_events OS_TRACE_STOP_AFTER_N_EVENTS -1 "STOP_AFTER_N_EVENTS is intended for tests of the ring buffer mode (when RECORDER_STORE_MODE is STORE_MODE_RING_BUFFER)."

add_sw_setting boolean system_h_define use_implicit_ife_rules OS_TRACE_USE_IMPLICIT_IFE_RULES 1 "Instance Finish Events"

add_sw_setting quoted_string system_h_define team_license_code OS_TRACE_TEAM_LICENSE_CODE "" "If no team license is available, this should be an empty string."
