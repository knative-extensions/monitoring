local g = import './lib/g.libsonnet';

local row = g.panel.row;
local panels = import './lib/panels.libsonnet';
local variables = import './lib/variables.libsonnet';
local queries = import './lib/queries.libsonnet';

local labels = {
  namespace: 'kourier-system',
  pod: '3scale-kourier-gateway-.*',
};


local q = queries.queries(labels);

g.dashboard.new('Knative Serving - Kourier Gateway')
+ g.dashboard.withUid('kourier-gateway')
+ g.dashboard.withDescription('A Dashboard that shows the state of the Kourier Gateways for Knative.')
+ g.dashboard.graphTooltip.withSharedCrosshair()
+ g.dashboard.withRefresh('60s')
+ g.dashboard.withTags(['Knative'])
+ g.dashboard.withVariables([
  variables.datasource,
])
+ g.dashboard.withPanels(
  g.util.grid.makeGrid([

    row.new('Overall Metrics'),

    panels.timeSeries.stat('Total Bytes Received', q.bytesReceived)
    + g.panel.stat.standardOptions.withUnit('bytes'),

    panels.timeSeries.stat('Total Bytes Sent', q.bytesSent)
    + g.panel.stat.standardOptions.withUnit('bytes'),

    panels.timeSeries.stat('Total Requests', q.requestsTotal),

    row.new('Request Metrics'),

    panels.timeSeries.base('Total Requests / sec', q.rpsTotal)
    + g.panel.timeSeries.standardOptions.withUnit('reqps'),

    panels.timeSeries.base('Requests / sec by Code', q.rpsByCode)
    + g.panel.timeSeries.standardOptions.withUnit('reqps'),

    panels.timeSeries.base('Requests / sec by Gateway', q.rpsByPod)
    + g.panel.timeSeries.standardOptions.withUnit('reqps'),

    panels.timeSeries.short('Active Requests by Gateway', q.activeRequestsByPod),
    panels.timeSeries.short('Total Active Requests', q.activeRequestsTotal),

  ], panelWidth=6)
)
