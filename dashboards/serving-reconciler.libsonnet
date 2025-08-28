local g = import './lib/g.libsonnet';

local row = g.panel.row;

local panels = import './lib/panels.libsonnet';
local variables = import './lib/variables.libsonnet';

local labels = { namespace: 'knative-serving' };

local reconciler(name, labels) =
  local q = (import './lib/queries.libsonnet').queries(labels);

  row.new(name)
  + row.withPanels([
    panels.timeSeries.short('Queue Depth', q.wqDepth, 'Reconciler queue depth'),
    panels.timeSeries.durationQuantile('Queue Processing Times', q.wqProcessingTimes, 'Time it takes to process items in the queue'),
  ]);

g.dashboard.new('Knative Serving - Reconciler')
+ g.dashboard.withDescription(|||
  Dashboard for Knative Serving Control Plane Reconciler Metrics
  (https://github.com/knative/serving)
|||)
+ g.dashboard.graphTooltip.withSharedCrosshair()
+ g.dashboard.withVariables([
  variables.datasource,
])
+ g.dashboard.withPanels(
  g.util.grid.makeGrid([
    reconciler('Knative Service', labels { reconciler: 'knative.dev.serving.pkg.reconciler.service.Reconciler' }),
    reconciler('Knative Route', labels { reconciler: 'knative.dev.serving.pkg.reconciler.route.Reconciler' }),
    reconciler('Knative Configuration', labels { reconciler: 'knative.dev.serving.pkg.reconciler.configuration.Reconciler' }),
    reconciler('Knative Revision', labels { reconciler: 'knative.dev.serving.pkg.reconciler.revision.Reconciler' }),
  ], panelWidth=8)
)
