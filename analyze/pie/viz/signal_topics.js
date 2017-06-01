d3.json('results/hackingteam_topics.json', function(error, data){
    var chart = c3.generate({
	bindto: '#chart1',
	data: {
	    columns: data,
	    type: 'pie'
	}
    });
});
