local g = import './g.libsonnet';
local q = g.query.prometheus;

local variables = import './variables.libsonnet';

local query = import './lib-query.libsonnet';
local sum = query.sum;
local rate = query.rate;
local irate = query.irate;
local labels = query.labels;
local round = query.round;
local quantile = query.quantile;
local increase = query.increase;

{
  queries(names):
    local namespaceLabels = {
      namespace: names.namespace,
    };
    local podLabels = {
      pod: '~' + names.pod,
      namespace: names.namespace,
    };
    local containerLabels = podLabels { container: names.container };
    local stackMemory = {
      go_memory_type: 'stack',
    };
    local reconcilerLabels = {
      name: names.reconciler,
    };
    local heapMemory = {
      go_memory_type: 'other',
    };
    {
      query(legend, query):
        self.rawQuery(query)
        + q.withLegendFormat(legend),

      rawQuery(query):
        q.new(
          '$' + variables.datasource.name,
          std.rstripChars(query, '\n')
        ),

      cpuUsage:
        self.query(
          'Container ({{pod}})',
          sum(irate(labels('container_cpu_usage_seconds_total', containerLabels)), by=['pod'])
        ),

      goMemoryUsage: [
        self.query(
          'Container ({{pod}})',
          sum(labels('container_memory_working_set_bytes', containerLabels), by=['pod'])
        ),
        self.query(
          'Stack ({{pod}})',
          sum(labels('go_memory_used_bytes', podLabels + stackMemory), by=['pod'])
        ),
        self.query(
          'Heap (In Use) ({{pod}})',
          sum(labels('go_memory_used_bytes', podLabels + heapMemory), by=['pod'])
        ),
        self.query(
          'Heap (Allocated) ({{pod}})',
          sum(labels('go_memstats_heap_alloc_bytes', podLabels), by=['pod'])
        ),
      ],

      goAllocations: [
        self.query(
          'Bytes ({{pod}})',
          sum(rate(labels('go_memory_allocated_bytes_total', podLabels)), by=['pod'])
        ),
        self.query(
          'Objects ({{pod}})',
          sum(rate(labels('go_memory_allocations_total', podLabels)), by=['pod'])
        ),
      ],

      goroutines:
        self.query(
          'Goroutines ({{pod}})',
          sum(labels('go_goroutine_count', podLabels), by=['pod'])
        ),

      wqDepth:
        self.query(
          '{{name}}',
          sum(labels('kn_workqueue_depth', reconcilerLabels), by=['pod'])
        ),

      wqProcessingTimes: [
        self.query(
          'P50',
          quantile(0.5, sum(rate(labels('kn_workqueue_queue_duration_seconds_bucket', reconcilerLabels)), by=['le'])),
        ),
        self.query(
          'P90',
          quantile(0.90, sum(rate(labels('kn_workqueue_queue_duration_seconds_bucket', reconcilerLabels)), by=['le'])),
        ),
        self.query(
          'P99',
          quantile(0.99, sum(rate(labels('kn_workqueue_queue_duration_seconds_bucket', reconcilerLabels)), by=['le'])),
        ),
      ],

    },
}
