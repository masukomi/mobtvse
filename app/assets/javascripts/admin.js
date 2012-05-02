function countChar(val){
     var len = val.value.length;
     var description_counter = document.getElementById('description_counter')
     var remaining = (156 - len);
     description_counter.innerText= remaining;
};
