function add(){
  sum=$(( $1 + $2 ))
  echo $sum
  
}

result=$(add 3 5)
echo "The result is $result"