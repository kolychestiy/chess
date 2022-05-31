#!/bin/bash

declare -a a

declare -i wx
declare -i wy

declare -i bx
declare -i by

declare -i rx
declare -i ry

declare -i x
declare -i y

declare -i buf_x
declare -i buf_y

declare -i check=0
declare -i pat=0
declare -i correct=0

declare -a arr_x
declare -a arr_y
declare -i sz_am

declare -a abc=(a b c d e f g h)

declare -i sz=8
declare -i scaleX=4
declare -i scaleY=8

function read_config(){
	read 
	read 
	read 
	read scaleX

	read 
	read 
	read 
	read scaleY
} < config.txt

function print_filed(){
	clear -x
	
	declare -i midX=$(($scaleX/2))
	declare -i midY=$(($scaleY/2))

	echo
	echo -en "     "
	for (( i = 0; i < sz; i++ )); do
		for (( j = 0; j < scaleY; j++ )); do
			if [ $j -eq $midY ]; then
				echo -en "\033[3;32m${abc[$i]}\033[0m"
			else 
				echo -n ' '
			fi
		done
	done
	echo
	echo

	for (( i = 0; i < scaleX*sz; i++ )); do
		x=$((i/scaleX))

		if [ $(($i%scaleX)) -eq $midX ]; then
			echo -en "  \033[3;32m$(($sz-$(($i/$scaleX))))\033[0m  "
		else
			echo -n "     "
		fi


		for (( j = 0; j < scaleY*sz; j++ )); do
			y=$((j/scaleY))
			field_col=40
			if [ $((${x}%2)) = $((${y}%2)) ];
				then field_col=107
			fi

			fig_col=97
			figure=" "

			if [ $x -eq $wx -a $y -eq $wy ]; then
				figure="K"
				field_col=100
			fi
			if [ $x -eq $rx -a $y -eq $ry ]; then
				figure="R"
				field_col=100
			fi
			if [ $x -eq $bx -a $y -eq $by ]; then
				figure="K"
				fig_col=30
				field_col=100
			fi

			echo -en "\033[1;${fig_col};${field_col}m${figure}\033[0m"
		done
		echo
	done
	echo
}

function upd_check(){
	check=0
	if [ $bx -eq $rx ]; then
		if [ $bx -ne $wx ]; then
			check=1
		elif [ $by -gt $wy -a $ry -gt $wy ]; then
			check=1
		elif [ $by -lt $wy -a $ry -lt $wy ]; then
			check=1
		fi
	fi

	if [ $by -eq $ry ]; then
		if [ $by -ne $wy ]; then
			check=1
		elif [ $bx -gt $wx -a $rx -gt $wx ]; then
			check=1
		elif [ $bx -lt $wx -a $rx -lt $wx ]; then
			check=1
		fi
	fi

	if [ $bx -eq $rx -a $by -eq $ry ]; then
		check=0
	fi
}

function upd_correct(){
	correct=1
# при ходе белых невозможно сьесть короля (другая проверка недопустит)
# при ходе черных возможно сьесть ладью
	# elif [ $bx -eq $rx -a $by -eq $ry ]; then
	# 	correct=0
	if [ $rx -eq $wx -a $ry -eq $wy ]; then
		correct=0
	fi
	if [ $(($bx-$wx)) -gt -2 -a $(($bx-$wx)) -lt 2 -a $(($by-$wy)) -gt -2 -a $(($by-$wy)) -lt 2 ]; then
		correct=0
	fi
}

function get_move(){
	sz_am=0

	buf_x=$bx
	buf_y=$by

	for (( i = -1; i <= 1; i++ )); do
		for (( j = -1; j <= 1; j++ )); do
			if [ $i -eq $j ]; then
				continue
			fi

			bx=$(($buf_x+$i))
			by=$(($buf_y+$j))

			if [ $bx -eq -1 -o $bx -eq 8 -o $by -eq -1 -o $by -eq 8 ]; then
				continue
			fi

			upd_correct

			if [ $correct -eq 0 ]; then
				continue
			fi

			upd_check

			if [ $check -eq 1 ]; then
				continue
			fi

			arr_x[$sz_am]=$bx
			arr_y[$sz_am]=$by
			sz_am=$(($sz_am+1))
		done
	done

	bx=$buf_x
	by=$buf_y
}

function move(){
	get_move
	declare -i i=$(($RANDOM%$sz_am))
	bx=${arr_x[$i]}
	by=${arr_y[$i]}
}

function upd_pat(){
	get_move
	pat=0
	if [ $sz_am -eq 0 ]; then
		pat=1
	fi
}


# начало выполнения программы

read_config

while [ $check -eq 1 -o $correct -ne 1 ]; do
	wx=$(($RANDOM%$sz))
	wy=$(($RANDOM%$sz))

	bx=$(($RANDOM%$sz))
	by=$(($RANDOM%$sz))

	rx=$(($RANDOM%$sz))
	ry=$(($RANDOM%$sz))

	upd_check
	upd_correct
done


while [ $0 ]; do

	print_filed
	echo -n 'Ваш ход. формат ввода [r/k][a-h][1-8]: '

	while [ $0 ]; do
		read ans

		if [ ${#ans} -lt 3 ]; then
			print_filed
			echo -n 'ввод содержит меньше символов, чем необходимо. формат ввода [r/k][a-h][1-8]: '
			continue
		fi

		c=${ans:0:1}

		if [ $c = 'r' -o $c = 'R' ]; then
			figure='r'
		elif [ $c = 'k' -o $c = 'K' ]; then
			figure='k'
		else
			print_filed
			echo -n 'неправильно указан тип фигуры (1 символ). формат ввода [r/k][a-h][1-8]: '		
			continue
		fi


		c=${ans:1:1}
		y=-1

		for (( i = 0; i < 8; i++ )); do
			if [ $c = ${abc[$i]} ]; then
				y=$i
			fi
		done
		
		if [ $y -eq -1 ]; then
			print_filed
			echo -n 'неправильно указана вертикаль (2 символ). формат ввода [r/k][a-h][1-8]: '		
			continue
		fi


		c=${ans:2:1}
		if [[ $c =~ '[^1-8]' ]]; then
			print_filed
			echo -n 'неправильно указана горизонталь (3 символ). формат ввода [r/k][a-h][1-8]: '		
			continue
		fi

		x=$((8-$c))
		declare -i no_cor=0

		if [ $figure = 'r' ]; then
			if [ $ry -eq $y -a $rx -eq $x ]; then
				no_cor=1
			elif [ $rx -ne $x -a $ry -ne $y ]; then
				no_cor=1
			elif [ $rx -eq $x -a $x -eq $wx ]; then
				if [ $ry -gt $wy -a $y -lt $wy ]; then
					no_cor=1
				fi
				if [ $ry -lt $wy -a $y -gt $wy ]; then
					no_cor=1
				fi				
			elif [ $ry -eq $y -a $y -eq $wy ]; then
				if [ $rx -gt $wx -a $x -lt $wx ]; then
					no_cor=1
				fi
				if [ $rx -lt $wx -a $x -gt $wx ]; then
					no_cor=1
				fi
			fi
			buf_x=rx
			buf_y=ry
			rx=x
			ry=y
		else
			if [ $wy -eq $y -a $wx -eq $x ]; then
				no_cor=1
			elif [ $(($wx-$x)) -lt -1 -o $(($wx-$x)) -gt 1 ]; then
				no_cor=1
			elif [ $(($wy-$y)) -lt -1 -o $(($wy-$y)) -gt 1 ]; then
				no_cor=1
			fi
			buf_x=wx
			buf_y=wy
			wx=x
			wy=y		
		fi


		upd_correct

		if [ $correct -eq 0 -o $no_cor -eq 1 ]; then
			if [ $figure = 'r' ]; then
				rx=buf_x
				ry=buf_y
			else
				wx=buf_x
				wy=buf_y		
			fi

			print_filed
			echo -n 'невозможный ход. формат ввода [r/k][a-h][1-8]: '		
			continue
		fi

		break
	done

	upd_pat
	upd_check

	if [ $pat -eq 1 -a $check -eq 1 ]; then
		print_filed
		echo 'Вы успешно заматовали соперника!'
		echo 'Для продолжения нажмите любую клавишу'
		read kek
		break
	fi

	if [ $pat -eq 1 ]; then
		print_filed
		echo 'Пат. ничья'
		echo 'Для продолжения нажмите любую клавишу'
		read kek
		break		
	fi

	print_filed

	move

	if [ $bx -eq $rx -a $by -eq $ry ]; then
		print_filed
		echo 'Недостаточно фигур для мата. ничья'
		echo 'Для продолжения нажмите любую клавишу'
		read kek
		break				
	fi

done

exit 0