#pragma once
#include <duckdb.h>
#include <duckdb.hpp>
#include <arrow/c/bridge.h>
#include <arrow/io/memory.h>
#include <arrow/ipc/writer.h>
#include <arrow/buffer.h>

extern "C" {
    typedef struct {
        void* address;
        int64_t size;
    }arrow_result;
    
    duckdb_database dab_open(const char* path);
    duckdb_connection dab_connect(duckdb_database db);
    duckdb_result* dab_query(duckdb_connection con, const char* query);
    arrow_result* dab_query_arrow(duckdb_connection con, const char* query);
    void * dab_arrow_address (arrow_result* result);
    int64_t dab_arrow_size (arrow_result* result);
    void dab_disconnect(duckdb_connection con);
    void dab_close(duckdb_database db);       
}  