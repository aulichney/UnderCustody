import { select } from 'd3'
import { prepareData, transformData } from './prepareData';

//Title case function for axis title formatting
function capitalizeFirstLetter(string) {
  return string.charAt(0).toUpperCase() + string.slice(1);
}

//Both json and csv gist urls -- set up for json currently
const dataUrl = 'https://gist.githubusercontent.com/aulichney/d4589c85658f1a2248b143dfd62005b4/raw/1b7c1826210517d3baa7c687de2b21e11ccdb1bf/undercustodymod.json'
//const dataUrl = 'https://gist.githubusercontent.com/aulichney/f60a198f6551aaafd29a91c56f70a184/raw/7e3cfb21baa0e3b6d6b3f86cae58b36bdb46ecdc/undercustodymod.csv'
const svg = select('svg')
const margin = {top: 48, right: 72, bottom: 120, left: 72}
const height = parseInt(svg.style('height'), 10) - margin.top - margin.bottom
const width = parseInt(svg.style('width'), 10) - margin.left - margin.right
const group = svg
  .append('g')
  .attr('transform', 'translate(' + margin.left + ',' + margin.top + ')');

// Set up bands and gaps between bands
const x = d3.scaleBand().padding(0.2)
const y = d3.scaleLinear()
// Store  raw unnested & nested data globally, avoid passing  to every function
let unNestedData
let nestedData

//Initial graph conditions
let yVar =  "amount"
let xVar = "sex"

makeVisualization()

async function makeVisualization(){
  unNestedData = await prepareData(dataUrl)
  nestedData = transformData(unNestedData, xVar)
  const xFields = Object.keys(unNestedData[0]);
	const yFields = Object.keys(nestedData[0].value);

  setupInput(yFields, xFields)
	setupScales()
  setupAxes()
  //Render bars
  selectionChangedX()
}

//Change y axis upon user input variable
function selectionChangedY(){
  //'this' is selected form element
  console.log("Changing y axis to reflect this variable", this.value)
	yVar = this.value
  y.domain([0, d3.max( nestedData.map(preference => preference.value[yVar]) )] );
  //update bars
  svg.selectAll('.bar')
    .attr('y', d => y(d.value[yVar]))
    .attr('height', d => height - y(d.value[yVar]))
  svg.select('.axis-y')
      .call(d3.axisLeft(y).ticks(10))
  group
  	.append("text")
    .attr("transform", "rotate(-90)")
    .attr("y", 0 - margin.left)
    .attr("x",0 - (height / 2))
    .attr("dy", "1em")
    .style("text-anchor", "middle")
    .text(capitalizeFirstLetter(yVar))
}

//Change x axis upon user input variable
function selectionChangedX(){
  xVar = this ? this.value : xVar
  console.log("Changing x axis to reflect this variable", xVar)
  nestedData = transformData(unNestedData, xVar)
  	//Sort on the key
    .sort((a,b) => d3.ascending(parseInt(a.key), parseInt(b.key)))
  x.domain(nestedData.map(item => item.key))
  // Change domain with new y max
  y.domain([0, d3.max( nestedData.map(preference => preference.value[yVar]) )] );
  const bars = group.selectAll('.bar')
  	.data(nestedData)
	console.log(bars)

  bars
   	.attr('x', d => x(d.key))
    .attr('y', d => y(d.value[yVar]))
    .attr('width', x.bandwidth())
    .attr('height', d => height - y(d.value[yVar]))

  bars
  	.enter()
  	.append('rect')
      .attr('class', 'bar')
  		.attr('x' ,d => x(d.key))
      .attr('y', d => y(d.value[yVar]))
      .attr('width', x.bandwidth())
      .attr('height', d => height - y(d.value[yVar]))

  bars
    .exit()
    .remove()
  //Update Axes ticks
  svg.select('.axis-x')
      .call(d3.axisBottom(x)).attr('transform', 'translate(0,' + height + ')')
  svg.select('.axis-y')
      .call(d3.axisLeft(y).ticks(10))
}

function setupScales(){
  //Set x domain based on preference selection
  x.domain(nestedData.map(preference => preference.key))
  //Set y domain based on preference selection
  y.domain([0, d3.max( nestedData.map(preference => preference.value[yVar]) )] )
  x.rangeRound([0, width]);
  y.rangeRound([height, 0]);
}

function setupAxes(){
  group
    .append('g')
    .attr('class', 'axis axis-x')
  	.call(d3.axisBottom(x)).attr('transform', 'translate(0,' + height + ')')
  group
    .append('g')
    .attr('class', 'axis axis-y')
  	.call(d3.axisLeft(y).ticks(10))
  group
    .append("text")
    .attr("transform", "rotate(-90)")
    .attr("y", 0 - margin.left)
    .attr("x",0 - (height / 2))
    .attr("dy", "1em")
    .style("text-anchor", "middle")
    .text(capitalizeFirstLetter(yVar);
}
}

//Create preference options based on dataset variables
function setupInput(yFields, xFields){
	d3.select('form')
    .append('select')
  	.text("Select a text value")
    .on('change', selectionChangedY)
    .selectAll('option')
    .data(yFields)
    .enter()
    .append('option')
    	.attr('value', d => d)
    	.text(d => "y-axis variable: " + d)
  		.property("selected", d => d === yVar)
  d3.select('form')
    .append('select')
    .on('change', selectionChangedX)
    .selectAll('option')
    .data(xFields)
    .enter()
    .append('option')
    	.attr('value', d => d)
    	.text(d => "x-axis variable: " + d)
  		.property("selected", d => d === xVar)
}
