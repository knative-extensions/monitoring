local g = import 'g.libsonnet';

local row = g.panel.row;

local panels = import './lib-panels.libsonnet';
local variables = import './variables.libsonnet';
local queries = import './queries.libsonnet';

local labels = { namespace: 'knative-serving' };


local efficiency(name, labels) =
  local q = (import './queries.libsonnet').queries(labels);

  row.new(name)
  + row.withPanels([
    panels.timeSeries.base('CPU Usage', q.cpuUsage, 'CPU usage of each running instance'),
    panels.timeSeries.bytes('Memory Usage', q.goMemoryUsage, 'Memory usage of each running instance'),
    panels.timeSeries.allocations('Memory Allocations', q.goAllocations, 'Details about memory allocations'),
    panels.timeSeries.short('Goroutines', q.goroutines, 'Goroutine count for each running instance'),
  ]);


g.dashboard.new('Knative Serving - Control Plane Efficiency')
+ g.dashboard.withDescription(|||
  Dashboard for Knative Serving Control Plane Efficiency
  (https://github.com/knative/serving)
|||)
+ g.dashboard.graphTooltip.withSharedCrosshair()
+ g.dashboard.withVariables([
  variables.datasource,
])
+ g.dashboard.withPanels(
  g.util.grid.makeGrid([
    efficiency('Activator', labels { container: 'activator', pod: 'activator-.*' }),
    efficiency('Autoscaler', labels { container: 'autoscaler', pod: 'autoscaler-.*' }),
    efficiency('Controller', labels { container: 'controller', pod: 'controller-.*' }),
    efficiency('Webhook', labels { container: 'webhook', pod: 'webhook-.*' }),
  ], panelWidth=6)
)
