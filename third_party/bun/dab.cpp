#include <math.h>
#include <dab.h>
#include <string.h>

using namespace duckdb;
using namespace std;


duckdb_database dab_open(const char* path) {
  duckdb_database db;
  if (DuckDBError == duckdb_open(path, &db)) return 0;
  return db;
}
duckdb_connection dab_connect(duckdb_database db) {
  duckdb_connection con;
  if (DuckDBError == duckdb_connect(db, &con)) return 0;
  return con;
}
duckdb_result* dab_query(duckdb_connection con, const char* query){
  duckdb_result *res = (duckdb_result*)malloc(sizeof(duckdb_result));
  if (DuckDBError == duckdb_query(con, query, res)) return 0;
  return res;
};
void query_arrow(duckdb_connection con, const char* query, arrow_result* out) {
  duckdb_arrow arrow_result = nullptr;
  if (duckdb_query_arrow(con, query, &arrow_result) == DuckDBError){   
      fprintf(stderr, "Failed to query arrow-query.\n");
  }
  ArrowSchema *arrow_schema = new ArrowSchema();
  duckdb_query_arrow_schema(arrow_result, (duckdb_arrow_schema *)&arrow_schema);
  auto schema = arrow::ImportSchema(arrow_schema);
  auto output_stream = arrow::io::BufferOutputStream::Create();
  auto batch_writer = arrow::ipc::MakeStreamWriter(*output_stream, *schema);
  while (true) {
    ArrowArray *arrow_array = new ArrowArray();
    duckdb_query_arrow_array(arrow_result, (duckdb_arrow_array *)&arrow_array);
    if( arrow_array->length > 0) {
      auto recordbatch = arrow::ImportRecordBatch(arrow_array,*schema);
      (*batch_writer)->WriteRecordBatch((const arrow::RecordBatch&) **recordbatch);
      delete arrow_array;
    }else{
      arrow_array->release;
      delete arrow_array;     
      break;
    }
  }
  auto stream = (*output_stream)->Finish();
  (*out).address = (void *)(*stream)->address();
  (*out).size = (*stream)->size();
  duckdb_destroy_arrow(&arrow_result);
}
arrow_result* dab_query_arrow(duckdb_connection con, const char* query) {
  arrow_result *res = (arrow_result*)malloc(sizeof(arrow_result));
  query_arrow(con, query, res);
  return res;
}
void * dab_arrow_address (arrow_result* result){return result->address;}
int64_t dab_arrow_size (arrow_result* result){return result->size;}
void dab_disconnect(duckdb_connection con) { duckdb_connection c = con; duckdb_disconnect(&c); }
void dab_close(duckdb_database db) { duckdb_database d = db; duckdb_close(&d); }