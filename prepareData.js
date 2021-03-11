import {mean} from 'd3'

export async function prepareData(url){
	//Load data
	let data = await loadData(url)
  // console.log("RawData: ", data)

  //Clean data
	data = data.map(cleanData)
  //console.log("cleanedData: ", data)

  return data
}


function loadData(url, query){
  return d3.json(url)
}


export function transformData(source, nestingVar){
  let transformed =  d3.nest()
		.key(d => d[nestingVar])
  	.rollup(d => {
      return {
        amount: d.length,
				ageAvg: d3.mean(d.map(correspondent => correspondent.age)),
        avgTimeServed: d3.mean(d.map(correspondent => correspondent.timeServed))
      }
    })
		.entries(source);
  //console.log("transformed data:", transformed)
  return transformed
}

//This part doesn't work, goal is to filter out empty rows for given property
//function filterData(row, property){
 //return row[property] != " " && row[property] != undefined
//}

//Retrieve columns of interest from data (note that excluding age results in failure)
function cleanData(row){
  return {
    sex: row.sex,
    age: Number(row.age),
    raceEthnicity: row.raceEthnicity,
    timeServed: row.timeServed

  }
}
