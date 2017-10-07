$(function() {
  // Fuel per 100k data //
  var fuel_data = [{
    "period": "2013-01",
    "city": 66,
    "highway": 34,
    "idle": 9
  }, {
    "period": "2013-02",
    "city": 62,
    "highway": 33,
    "idle": 8
  }, {
    "period": "2013-03",
    "city": 61,
    "highway": 32,
    "idle": 7
  }, {
    "period": "2013-04",
    "city": 66,
    "highway": 32,
    "idle": 6
  }, {
    "period": "2013-05",
    "city": 67,
    "highway": 31,
    "idle": 5
  }, {
    "period": "2013-06",
    "city": 68,
    "highway": 43,
    "idle": 7
  }, {
    "period": "2013-07",
    "city": 62,
    "highway": 32,
    "idle": 5
  }, {
    "period": "2013-08",
    "city": 61,
    "highway": 32,
    "idle": 5
  }, {
    "period": "2013-09",
    "city": 58,
    "highway": 32,
    "idle": 7
  }, {
    "period": "2013-10",
    "city": 60,
    "highway": 32,
    "idle": 7
  }, {
    "period": "2013-11",
    "city": 60,
    "highway": 32,
    "idle": 6
  }, {
    "period": "2013-12",
    "city": 62,
    "highway": 32,
    "idle": 8
  }];
  Morris.Line({
    element: 'fuel-consumption',
    hideHover: 'auto',
    data: fuel_data,
    xkey: 'period',
    xLabels: 'month',
    ykeys: ['city', 'highway', 'idle'],
    postUnits: ' l/100km',
    labels: ['City', 'Highway', 'Idle'],
    resize: true,
    lineColors: ['#A52A2A', '#72A0C1', '#7BB661']
      //yLabelFormat: function(y) { return y.toString() + ' l/100km'; }
  });
  // / Fuel per 1000k data //
  // Fuel projection //
  Morris.Donut({
    element: 'fuel-projection',
    hideHover: 'auto',
    resize: true,
    data: [{
      label: 'Consumption until today',
      value: 180
    }, {
      label: 'Projected consumption',
      value: 400
    }, ],
    colors: ['#7BB661', '#72A0C1'],
    formatter: function(y) {
      return y + " liters"
    }
  });
  // / Fuel projection //
  // CO2 Emissons //
  bar = Morris.Bar({
    element: 'co2-emissions',
    resize: true,
    data: [{
      month: 'Jan',
      emissions: 35
    }, {
      month: 'Feb',
      emissions: 37
    }, {
      month: 'Mar',
      emissions: 40
    }, {
      month: 'Apr',
      emissions: 38
    }, {
      month: 'Maj',
      emissions: 39
    }, {
      month: 'Jun',
      emissions: 42
    }, {
      month: 'Jul',
      emissions: 37
    }, {
      month: 'Aug',
      emissions: 65
    }, {
      month: 'Sep',
      emissions: 38
    }, {
      month: 'Okt',
      emissions: 45
    }, {
      month: 'Nov',
      emissions: 41
    }, {
      month: 'Dec',
      emissions: 41
    }],
    xkey: 'month',
    ykeys: ['emissions'],
    labels: ['Co2 emissions'],
    barRatio: 0.4,
    xLabelAngle: 35,
    hideHover: 'auto',
    postUnits: ' g/km',
    formatter: function(y) {
      return y + " g/km"
    }
  });
});
