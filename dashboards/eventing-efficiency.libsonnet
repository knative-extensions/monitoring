local g = import './lib/g.libsonnet';

local row = g.panel.row;

local panels = import './lib/panels.libsonnet';
local variables = import './lib/variables.libsonnet';

local labels = { namespace: 'knative-eventing' };

local efficiency(name, labels) =
  local q = (import './lib/queries.libsonnet').queries(labels);

  row.new(name)
  + row.withPanels([
    panels.timeSeries.base('CPU Usage', q.cpuUsage, 'CPU usage of each running instance'),
    panels.timeSeries.bytes('Memory Usage', q.goMemoryUsage, 'Memory usage of each running instance'),
    panels.timeSeries.allocations('Memory Allocations', q.goAllocations, 'Details about memory allocations'),
    panels.timeSeries.short('Goroutines', q.goroutines, 'Goroutine count for each running instance'),
  ]);


g.dashboard.new('Knative Eventing - Control Plane Efficiency')
+ g.dashboard.withDescription(|||
  Dashboard for Knative Eventing Control Plane Efficiency
  (https://github.com/knative/eventing)
|||)
+ g.dashboard.graphTooltip.withSharedCrosshair()
+ g.dashboard.withVariables([
  variables.datasource,
])
+ g.dashboard.withPanels(
  g.util.grid.makeGrid([
    efficiency('Controller', labels { container: 'eventing-controller', pod: 'eventing-controller-.*' }),
    efficiency('Webhook', labels { container: 'eventing-webhook', pod: 'eventing-webhook-.*' }),
  ], panelWidth=6)
)
