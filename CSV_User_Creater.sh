#!/bin/bash

#초기화된 변수 모음
count_ok=0
name_ok=0
password_ok=0
project_ok=0
email_ok=0
description_ok=0
count_p=0
name_p=0
password_p=0
project_p=0
email_p=0
description_p=0
da='$'
name_s=""
tests=0
deletes=0

#도움말 -h입력을 받으면 출력
if [ "$1" == "h-" ]; then
	echo "--------------------------------------------[설명]----------------------------------------------"
	echo "이 프로그램은 OpenStack에서 다수의 계정을 생성할 수 있도록 제작된 프로그램입니다."
	echo ""
	echo "---------------------------------------[명령어 사용법]------------------------------------------"
	echo "CSV_User_Creater.sh [csv파일 이름] [옵션]..."
	echo ""
	echo "------------------------------------[옵션 종류 밑 사용법]---------------------------------------"
	echo " Help=               : 프로그램 설명 및 사용법 설명"
	echo " Count=[숫자]        : csv파일에서 [숫자]번째 필드를 카운트로 설정 (1에서 n까지 정렬된 필드) {필수 옵션}"
	echo " Name=[숫자]         : csv파일에서 [숫자]번째 필드를 계정 이름으로 설정                      {필수 옵션}"
	echo " Password=[숫자]     : csv파일에서 [숫자]번째 필드를 계정 암호로 설정                        {필수 옵션}"
	echo " Project=[숫자]      : csv파일에서 [숫자]번째 필드를 계정 프로젝트 이름으로 설정             {필수 옵션}"
	echo " Email=[숫자]        : csv파일에서 [숫자]번째 필드를 E-Mail로 설정                           {선택 옵션}"
	echo " ProjectStr=[문자열] : [문자열]을 계정 프로젝트 이름으로 설정                                {필수 옵션}"
	echo " NameAdd=[문자열]    : [문자얼]을 계정이름 앞에 추가                                         {필수 옵션}"
	echo " Work=               : 기본인 테스트상태를 해제하고 작업을 실행                              {선택 옵션}"
	echo " Delete=             : 다음 계정들을 삭제                                                    {선택 옵션}"
	echo ""
	echo "------------------------------------------------------------------------------------------------"
	exit 0
fi

#받은 명령어 종류를 분별하여 필드번호 할당
SetOption()
{
	opt=$(awk -F= '{print $1}' <<< $SO)
	if [ "$opt" == "Name" ]; then #이름 위치
		name_p=$(awk -F= '{print $2}' <<< $SO)
		if [ "$name_p" == "" ]; then
			name_p=0
		fi
		name_ok=$((name_ok+1))
	elif [ "$opt" == "Password" ]; then #암호 위치
		password_p=$(awk -F= '{print $2}' <<< $SO)
		if [ "$password_p" == "" ]; then
			password_p=0
		fi
		password_ok=$((password_ok+1))
	elif [ "$opt" == "Count" ]; then #카운트 위치
		count_p=$(awk -F= '{print $2}' <<< $SO)
		if [ "$count_p" == "" ]; then
			count_p=0
		fi
		count_ok=$((count_ok+1))
	elif [ "$opt" == "Project" ]; then #프로젝트 위치
		project_p=$(awk -F= '{print $2}' <<< $SO)
		if [ "$project_p" == "" ]; then
			project_p=0
		fi
		project_ok=$((project_ok+1))
	elif [ "$opt" == "Email" ]; then #이메일 위치
		email_p=$(awk -F= '{print $2}' <<< $SO)
		if [ "$email_p" == "" ]; then
			email_p=0
		fi
		email_ok=$((email_ok+1))
	elif [ "$opt" == "Description" ]; then #이메일 위치
		description_p=$(awk -F= '{print $2}' <<< $SO)
		if [ "$description_p" == "" ]; then
			description_p=0
		fi
		description_ok=$((description_ok+1))
	elif [ "$opt" == "ProjectStr" ]; then #프로젝트 문자열 입력용
		project=$(awk -F= '{print $2}' <<< $SO)
		project_ok=$((project_ok+1))
	elif [ "$opt" == "NameAdd" ]; then #이름 앞에 추가할 것
		name_s=$(awk -F= '{print $2}' <<< $SO)
	elif [ "$opt" == "Work" ]; then #작업 실행
		tests=1
	elif [ "$opt" == "Delete" ]; then #계정 삭제
		deletes=1
	else
		#프로그램이 읽을 수 없는 명령어가 들어올 경우 안내문 출력후 프로그램 종료
		echo "------------------------------------------------------------------------------"
		echo "실행할 수 없는 명령어가 있습니다."
		echo "실행할 수 없는 명령어 : $SO"
		echo "------------------------------------------------------------------------------"
		exit 0
	fi
}

#받은 필드번호에 위치한 문자열을 반환
ReadPoint()
{
	if [ $RP -eq 0 ]; then #모든 포인트가 0으로 초기화되어있으므로 포인트가 0이면 받은 인자가 없다는 뜻
		RP=""
	else #0이 아니라면 그 필드를 읽어 문자열을 반환
		pri="{print $da$RP}"
		RP=$(awk -F, "$pri" <<< $line)
	fi
}

#csv파일에서 정보를 읽을 수 없을 경우의 안내문
Error1()
{
	echo "----------------------------------------------------------------------"
	echo "$str 에서 읽은 정보중에 읽을 수 없는 정보가 있습니다."
	echo "읽은 정보 개수 $count_c"
	echo "name     = $name_c"
	echo "password = $password_c"
	echo "project  = $project_c"
	echo "----------------------------------------------------------------------"
}

#Main
#$2~$9에 적힌 명령어를 읽어 필드번호를 할당
if [ "$2" != "" ]; then
	SO=$2
	SetOption
fi
if [ "$3" != "" ]; then
	SO=$3
	SetOption
fi
if [ "$4" != "" ]; then
	SO=$4
	SetOption
fi
if [ "$5" != "" ]; then
	SO=$5
	SetOption
fi
if [ "$6" != "" ]; then
	SO=$6
	SetOption
fi
if [ "$7" != "" ]; then
	SO=$7
	SetOption
fi
if [ "$8" != "" ]; then
	SO=$8
	SetOption
fi
if [ "$9" != "" ]; then
	SO=$9
	SetOption
fi
if [ "$9" != "" ]; then
	SO=${10}
	SetOption
fi

#명령어 입력이 정상이였는지 판별
if [ "$name_ok" != "1" -o "$password_ok" != "1" -o "$count_ok" != "1" -o $project_ok -ge 2 ]; then
		echo "--------------------[명령어 입력이 올바르지 않습니다.]-----------------------"
		echo "옵션은 -n(name) -p(password) -c(count)가 필수적으로 들어갑니다."
		echo "옵션이 중복되었거나 파일입력이 잘못되었을 수도 있습니다."
		echo "-----------------------------------------------------------------------------"
		echo "파일 이름: $1"
		echo "입력된 명령어 횟수"
		echo "name     = $name_ok"
		echo "password = $password_ok"
		echo "count    = $count_ok"
		echo "project  = $project_ok"
		echo "-----------------------------------------------------------------------------"
		exit 0
fi

#파일 정보가 올바른지 확인, 읽는데 문제가 있다면 안내문 출력후 프로그램 종료
count_c=0
name_c=0
password_c=0
project_c=0
count=1
while read line # 파일을 한번 훑어봄
do
	RP=$count_p
	ReadPoint
	count_r=$RP
	if [ "$count_r" == "$count" ]; then
		RP=$name_p
		ReadPoint
		name=$RP
		if [ "$name" != "" ]; then
			name_c=$((name_c+1))
		fi
		RP=$password_p
		ReadPoint
		password=$RP
		if [ "$password" != "" ]; then
			password_c=$((password_c+1))
		fi
		if [ "$project_p" != "0" ]; then
			RP=$project_p
			ReadPoint
			project=$RP
		fi
		if [ "$project" != "" ]; then
			project_c=$((project_c+1))
		fi
		count=$((count+1))
		count_c=$((count_c+1))
	fi
done < $1
#읽지 못하는 정보를 발견하면 안내문 출력후 프로그램 종료
if [ "$count_c" != "$name_c" -o "$count_c" != "$password_c" -o "$count_c" != "$project_c" ]; then
	if [ "$project_ok" != "0" -a "$count_c" != "$project_c" ]; then
		str=$1
		Error1
		exit 0
	fi
	if [ "$count_c" != "$name_c" -o "$count_c" != "$password_c" ]; then
		str=$1
		Error1
		exit 0
	fi
fi

#파일을 읽어 계정 생성
count=1
while read line
do
	RP=$count_p
	ReadPoint
	count_r=$RP
	if [ "$count_r" == "$count" ]; then
		RP=$name_p
		ReadPoint
		name=$RP
		RP=$password_p
		ReadPoint
		password=$RP
		if [ "$project_p" != "0" ]; then
			RP=$project_p
			ReadPoint
			project=$RP
		fi
		if [ "$email_p" != "0" ]; then
			RP=$email_p
			ReadPoint
			email=$RP
		fi
		if [ "$description_p" != "0" ]; then
			RP=$description_p
			ReadPoint
			description=$RP
		fi
		#계정생성부분
		if [ "$project" == "" ]; then
			echo "프로그램이 수정되어 프로젝트를 반드시 입력하셔야 합니다."
			break
		else
			if [ $tests -eq 0 ]; then # tests가 0이면 명령어 출력, tests가 1이면 명령어 실행
				if [ $deletes -eq 0 ]; then # deletes가 0이면 계정 생성, 1이면 계정 삭제
					if [ $email_ok -eq 1 ]; then # email 생성 실행
						echo "openstack user create --domain default --project $project --email $email --password $password $name_s$name"
					else
						echo "openstack user create --domain default --project $project --password $password $name_s$name"
					fi
					echo "openstack role add --project $project --user $name_s$name --user-domain default member"
				else
					echo "openstack user delete --domain default $name_s$name"
				fi
			else
				if [ $deletes -eq 0 ]; then
					if [ $email_ok -eq 1 ]; then # email 생성 실행
						openstack user create --domain default --project $project --email $email --description $description --password $password $name_s$name
					else
						openstack user create --domain default --project $project --password $password $name_s$name
					fi
					openstack role add --project $project --user $name_s$name --user-domain default member
				else
					openstack user delete --domain default $name_s$name
				fi
			fi
		fi
		count=$((count+1))
	fi
done < $1

echo "생성 계정 수 $((count-1))"

exit 0
