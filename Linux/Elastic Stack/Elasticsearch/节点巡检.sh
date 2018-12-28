#!/bin/bash

TMPLOG=`mktemp`

cat > elasticsearch.html <'EOF'
<!DOCTYPE HTML>
<html>
    <head>
    <meta charset="utf-8">
    <style>
    #tab{font-size:21;font-family:楷体}
    </style>
    </head>
    <body>
        <table id="tab" border="1" cellspacing="0" cellpadding="0">
            <tr>
                <th id="th0" onclick="SortTable(this)" class="as">name</th>
                <th id="th1" onclick="SortTable(this)" class="as">Pid</th>
                <th id="th2" onclick="SortTable(this)" class="as">http_address</th>
                <th id="th3" onclick="SortTable(this)" class="as">segments.count</th>
                <th id="th4" onclick="SortTable(this)" class="as">segments.memory</th>
                <th id="th5" onclick="SortTable(this)" class="as">disk.avail</th>
                <th id="th6" onclick="SortTable(this)" class="as">ram.max</th>
                <th id="th7" onclick="SortTable(this)" class="as">ram.current</th>
                <th id="th8" onclick="SortTable(this)" class="as">ram.percent</th>
                <th id="th9" onclick="SortTable(this)" class="as">heap.max</th>
                <th id="tha" onclick="SortTable(this)" class="as">hrap.current</th>
                <th id="thb" onclick="SortTable(this)" class="as">hrap.percent</th>
                <th id="thc" onclick="SortTable(this)" class="as">load_1m</th>
                <th id="thd" onclick="SortTable(this)" class="as">load_5m</th>
                <th id="the" onclick="SortTable(this)" class="as">load_15m</th>
            </tr>
        </table>
    </body>
</html>
<script type="text/javascript"> 
    var tag=1;
    function sortNumberAS(a, b)
    {
        return a - b    
    }
    function sortNumberDesc(a, b)
    {
        return b-a
    }
    function SortTable(obj){
        var td0s=document.getElementsByName("td0");
        console.log(td0s)
        var td1s=document.getElementsByName("td1");
        var td2s=document.getElementsByName("td2");
        var td3s=document.getElementsByName("td3");
        var td4s=document.getElementsByName("td4");
        var td5s=document.getElementsByName("td5");
        var td6s=document.getElementsByName("td6");
        var td7s=document.getElementsByName("td7");
        var td8s=document.getElementsByName("td8");
        var td9s=document.getElementsByName("td9");
        var tdas=document.getElementsByName("tda");
        var tdbs=document.getElementsByName("tdb");
        var tdcs=document.getElementsByName("tdc");
        var tdds=document.getElementsByName("tdd");
        var tdes=document.getElementsByName("tde");
        var tdArray0=[];
        var tdArray1=[];
        var tdArray2=[];
        var tdArray3=[];
        var tdArray4=[];
        var tdArray5=[];
        var tdArray6=[];
        var tdArray7=[];
        var tdArray8=[];
        var tdArray9=[];
        var tdArraya=[];
        var tdArrayb=[];
        var tdArrayc=[];
        var tdArrayd=[];
        var tdArraye=[];
        for(var i=0;i<td0s.length;i++){
            tdArray0.push(td0s[i].innerHTML);
        }
        for(var i=0;i<td1s.length;i++){
            tdArray1.push(parseInt(td1s[i].innerHTML));
        }
        for(var i=0;i<td2s.length;i++){
            tdArray2.push(parseInt(td2s[i].innerHTML));
        }
        for(var i=0;i<td3s.length;i++){
            tdArray3.push(parseInt(td3s[i].innerHTML));
        }
        for(var i=0;i<td4s.length;i++){
            tdArray4.push(parseInt(td4s[i].innerHTML));
        }
        for(var i=0;i<td5s.length;i++){
            tdArray5.push(parseInt(td5s[i].innerHTML));
        }
        for(var i=0;i<td6s.length;i++){
            tdArray6.push(parseInt(td6s[i].innerHTML));
        }
        for(var i=0;i<td7s.length;i++){
            tdArray7.push(parseInt(td7s[i].innerHTML));
        }
        for(var i=0;i<td8s.length;i++){
            tdArray8.push(parseInt(td8s[i].innerHTML));
        }
        for(var i=0;i<td9s.length;i++){
            tdArray9.push(parseInt(td9s[i].innerHTML));
        }
        for(var i=0;i<tdas.length;i++){
            tdArraya.push(parseInt(tdas[i].innerHTML));
        }
        for(var i=0;i<tdbs.length;i++){
            tdArrayb.push(parseInt(tdbs[i].innerHTML));
        }
        for(var i=0;i<tdcs.length;i++){
            tdArrayc.push(parseInt(tdcs[i].innerHTML));
        }
        for(var i=0;i<tdds.length;i++){
            tdArrayd.push(parseInt(tdds[i].innerHTML));
        }
        for(var i=0;i<tdes.length;i++){
            tdArraye.push(parseInt(tdes[i].innerHTML));
        }
        var tds=document.getElementsByName("td"+obj.id.substr(2,1));
        var columnArray=[];
        for(var i=0;i<tds.length;i++){
            columnArray.push(parseInt(tds[i].innerHTML));
        }
        var orginArray=[];
        for(var i=0;i<columnArray.length;i++){
            orginArray.push(columnArray[i]);
        }
        if(obj.className=="as"){
            columnArray.sort(sortNumberAS);
            obj.className="desc";
        }else{
            columnArray.sort(sortNumberDesc);
            obj.className="as";
        }
        for(var i=0;i<columnArray.length;i++){
            for(var j=0;j<orginArray.length;j++){
                if(orginArray[j]==columnArray[i]){
                    document.getElementsByName("td0")[i].innerHTML=tdArray0[j];
                    document.getElementsByName("td1")[i].innerHTML=tdArray1[j];
                    document.getElementsByName("td2")[i].innerHTML=tdArray2[j];
                    document.getElementsByName("td3")[i].innerHTML=tdArray3[j];
                    document.getElementsByName("td4")[i].innerHTML=tdArray4[j];
                    document.getElementsByName("td5")[i].innerHTML=tdArray5[j];
                    document.getElementsByName("td6")[i].innerHTML=tdArray6[j];
                    document.getElementsByName("td7")[i].innerHTML=tdArray7[j];
                    document.getElementsByName("td8")[i].innerHTML=tdArray8[j];
                    document.getElementsByName("td9")[i].innerHTML=tdArray9[j];
                    document.getElementsByName("tda")[i].innerHTML=tdArraya[j];
                    document.getElementsByName("tdb")[i].innerHTML=tdArrayb[j];
                    document.getElementsByName("tdc")[i].innerHTML=tdArrayc[j];
                    document.getElementsByName("tdd")[i].innerHTML=tdArrayd[j];
                    document.getElementsByName("tde")[i].innerHTML=tdArraye[j];
                    orginArray[j]=null;
                    break;
                }
            }
        }
    }
</script>
EOF

curl -s '192.168.157.11:9213/_cat/nodes?v&h=name,pid,http_address,segments.count,segments.memory,disk.avail,ram.max,ram.current,ram.percent,heap.max,heap.current,heap.percent,load_1m,load_5m,load_15m' \
| awk '{for(i=1;i<=NF;i++){printf $i","}print '\n'}' \
| sed 's/,$//' \
| awk -F',' '{print "<tr>" ; for(i=1;i<=NF;i++){print "    <td name=\"td"i"\">"$i"</td>"}print "</tr>"}' \
| sed -e 's/td1"/td0"/g' -e 's/td2"/td1"/g' -e 's/td3"/td2"/g' -e 's/td4"/td3"/g' -e 's/td5"/td4"/g' \
-e 's/td6"/td5"/g' -e 's/td7"/td6"/g' -e 's/td8"/td7"/g' -e 's/td9"/td8"/g' \
-e 's/td10"/td9"/g' -e 's/td11"/tda"/g' -e 's/td12"/tdb"/g' -e 's/td13"/tdc"/g' -e 's/td14"/tdd"/g'  -e 's/td15"/tde"/g' > ${TMPLOG}

vim +"24r ${TMPLOG}|wq!" elasticsearch.html
