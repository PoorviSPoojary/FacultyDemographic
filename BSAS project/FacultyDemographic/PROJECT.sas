
/*TO CREATE BT LIBRARY*/;
libname bt "/home/u63398064/data";
*********************************************************************************************************;

/*TO IMPORT EXCEL FILE*/
option validvarname=v7;

proc import datafile="/home/u63398064/data/faculty_demographics.xlsx" dbms=xlsx 
		out=bt.faculty replace;
run;

********************************************************************************************************;

data faculty_demographic;
	length name $25;
	set bt.faculty;
	gender=substr(gender, 1, 1);
	Cadre=propcase(cadre);
	if qualification="PHD"  /*ADDITION OF SALUATION ACCORDING TO QUALIFICATION*/
	then
		name=catX('', "DR.", name, surname);

	/*CATX FUNCTION USED TO CONCATENATE SALUTATION NAME AND SURNAME*/
	else if qualification="PG" and gender="M" then
		name=catx('', "MR.", name, surname);
	else
		name=catx('', "MS.", name, surname);
	/*NAME IN UPPERCASE*/
	name=upcase(name);
	/*TO CALCULATE THE AGE OF THE FACULTY*/
	age=yrdif(dob, today(), "age");
	format age 2.;
	*TO CALCULATE NUMBER OF YEARS WORKED IN PRESENT INSTITUTE*;
	present_exp=yrdif(doj, today(), "age");
	format present_exp 2.;
	*TO CALCULATE NUMBER OF YEARS WORKED IN PAST INSTITUTE*;
	past_exp=sum(total_exp, -present_exp);
	format past_exp 2. name 25.;
	*TO CALCULATE ANNUAL INCOME*;
	annual_income=salary_monthly*12;
	*TO CALCULATE ANNUAL EXPENSE*;
	annual_expense=expense_per_month*12;
	*TO CALCULATE ANNUAL SAVINGS*;
	savings=sum(annual_income, -annual_expense);
run;

************************************************************************************************************;
*QUESTION1*;
/*SORTING THE OBSERVATION ACCORDING TO DEPARTMENT AND CADRE*/
proc sort data=faculty_demographic out=faculty_sort;
	by dept descending Cadre;
run;

*************************************************************************************************************;
*EXPORT THE RESULTS AS PDF FILES*;
ods pdf file="/home/u63398064/output/bsas.pdf" startpage=yes style=sapphire 
	pdftoc=1;
options nodate;
ods noproctitle;
**************************************************************************************************************;

/*DEPARTMENT WISE FACULTY LIST WITH STAFF ID, NAME,CADRE,QUALIFICATION ,DOJ AND
EXPERIENCE SORTED ACCORDING TO CADRE*/
TITLE1 color=dabr "NMAM INSTITUTE OF TECHNOLOGY";
TITLE2 color=black bold height=4 "FACULTY DEMOGRAPHICS";
TITLE3 color=dabr"TABLE1 DEPARTMENT WISE FACULTY LIST";
TITLE4 color=darkgreen underlin=1"DEPT:BIOTECHNOLOGY ENGINEERING";

proc print data=faculty_sort label;
	where dept="BTE";
	var staff_id name cadre qualification doj total_exp;
	label total_exp="experience(years)" doj="date of joining";
run;

TITLE;
TITLE5 color=darkgreen underlin=1 "DEPT:COMPUTER SCIENCE ENGINEERING";

proc print data=faculty_sort label;
	where dept="CSE";
	var staff_id name cadre qualification doj total_exp;
	label total_exp="experience(years)" doj="date of joining";
run;

TITLE;
TITLE6 color=darkgreen underlin=1 "DEPT:CIVIL ENGINEERING";

proc print data=faculty_sort label;
	where dept="CVE";
	var staff_id name cadre qualification doj total_exp;
	label total_exp="experience(years)" doj="date of joining";
run;

TITLE;
TITLE7 color=darkgreen  underlin=1 "DEPT:ELECTRONICS AND COMMUNICATION ENGINEERING";

proc print data=faculty_sort label;
	where dept="ECE";
	var staff_id name cadre qualification doj total_exp;
	label total_exp="experience(years)" doj="date of joining";
run;

TITLE;
TITLE8 color=darkgreen underlin=1 "DEPT:MECHANICAL ENGINEERING";

proc print data=faculty_sort label;
	where dept="MEC";
	var staff_id name cadre qualification doj total_exp;
	label total_exp="experience(years)" doj="date of joining";
run;

TITLE;
***************************************************************************************************;

/*QUESTION2*/
/*PREPARATION OF SUMMARY STATISTICS TABLE*/
TITLE1 color=black"TABLE2 SUMMARY STATISTICS OF FACULTY";
TITLE2 color=darkgreen underlin=1"GENDER DISTRIBUTION";

PROC FREQ DATA=faculty_sort;
	tables gender /nocum;
run;

ods noproctitle;
TITLE;
***************************************************************************************************;

/*QUESTION 3*/
/* DEPARTMENT WISE PIE CHART FOR NUMBER OF FACULTY */
proc template;
	define statgraph SASStudio.Pie;
		begingraph;
		entrytitle "pie chart" / textattrs=(size=14);
		entryfootnote halign=center "FIG-1 DEPT WISE FOR NUMBER OF FACULTY" / 
			textattrs=(size=12);
		layout region;
		piechart category=Dept / start=90 categorydirection=clockwise 
			datalabellocation=inside datalabelattrs=(size=7) dataskin=matte;
		endlayout;
		endgraph;
	end;
run;

ods graphics / reset width=5in height=4in imagemap;

proc sgrender template=SASStudio.Pie data=WORK.FACULTY_SORT;
run;

ods graphics / reset;
************************************************************************************************;

/*DEPARTMENT WISE CLUSTERED BAR CHART FOR CADRE DISTRIBUTION*/
ods graphics / reset width=5in height=4in imagemap;

proc sgplot data=WORK.FACULTY_SORT;
	title height=14pt "CLUSTERED BAR CHART";
	footnote2 justify=center height=12pt 
		"FIG-2 DEPARTMENT WISE CADRE DISTRIBUTION";
	vbar Dept / group=Cadre groupdisplay=cluster fillType=solid dataskin=sheen;
	yaxis max=10 grid;
	keylegend / location=inside;
run;

ods graphics / reset;
title;
footnote2;
************************************************************************************************;
*QUESTION 4*;

/*TO CALCULATE AVERAGE EXPERIENCE DEPARTMENT WISE*/;
title1 color=BLACK"TABLE3 DEPARTMENT WISE AVERAGE EXPERIENCE OF FACULTY";
ods noproctitle;

proc means data=faculty_sort mean nonobs;
	var total_exp;
	class dept;
run;

title;
*************************************************************************************************;
*QUESTION 5*;

/*TO SORT THE TABLE IN DECREASING ORDER OF AGE*/
proc sort data=faculty_demographic out=faculty_age;
	by descending age;
run;

**************************************************************************************************;

/*TO PRINT THE TABLE WITH MALE FACULTY IN DECREASING ORDER OF AGE*/
title1 color=black "TABLE4 AGE OF THE FACULTY";
TITLE2 color=darkgreen underlin=1 "MALE";

proc print data=faculty_age;
	WHERE GENDER="M";
	var name dept age;
run;

TITLE;
************************************************************************************************;

/*TO PRINT THE TABLE WITH FEMALE FACULTY IN DECREASING ORDER OF AGE*/
TITLE3 color=darkgreen underlin=1"FEMALE";

proc print data=faculty_age;
	WHERE GENDER="F";
	var name dept age;
run;

TITLE;
************************************************************************************************;

/*QUESTION 6*/
/*TABLE SHOWING THE DEPARTMENT WISE EXPERIENCE DATA OF THE FACULTY SORTED ACCORDING TO
DESCENDING ORDER OF AGE*/
title1 COLOR=BLACK"TABLE5 DEPARTMENT WISE FACULTY EXPERIENCE LIST";
TITLE2 COLOR=DARKGREEN UNDERLIN=1 "BIOTECHNOLOGY ENGINEERING";

proc print data=faculty_age;
	where dept="BTE";
	var name age total_exp present_exp past_exp;
run;

title;
TITLE3 COLOR=DARKGREEN UNDERLIN=1 "COMPUTER SCIENCE ENGINEERING";

proc print data=faculty_age;
	where dept="CSE";
	var name age total_exp present_exp past_exp;
run;

title;
TITLE4 COLOR=DARKGREEN UNDERLIN=1 "CIVIL ENGINEERING";

proc print data=faculty_age;
	where dept="CVE";
	var name age total_exp present_exp past_exp;
run;

title;
TITLE5 COLOR=DARKGREEN UNDERLIN=1 "ELECTRONICS AND COMMUNICATION ENGINEERING";

proc print data=faculty_age;
	where dept="ECE";
	var name age total_exp present_exp past_exp;
run;

title;
TITLE5 COLOR=DARKGREEN UNDERLIN=1 "MECHANICAL ENGINEERING";

proc print data=faculty_age;
	where dept="MEC";
	var name age total_exp present_exp past_exp;
run;

title;
*************************************************************************************************;
*QUESTION 7*;
*PLOTTING DEPARTMENT WISE CLUSTERED BAR GRAPH FOR NUMBER OF JOURNALS PUBLISHED *;
ods graphics / reset width=6.5in height=4.5in imagemap;

proc sgplot data=WORK.FACULTY_SORT;
	title height=14pt "CLUSTERED BAR GRAPH FOR NUMBER OF JOURNALS PUBLISHED";
	footnote2 justify=center height=12pt 
		"FIG3.DATA ILLUSTRATING THE NUMBER OF JOURNALS PUBLISHED ";
	vbar Journals / group=Dept groupdisplay=cluster dataskin=sheen;
	xaxis label="number of journals published" valuesrotate=vertical;
	yaxis label="number of faculty";
	keylegend / location=outside;
run;

ods graphics / reset;
title;
footnote2;
***************************************************************************************************;
*QUESTION 8*;

/* TO GENERATE THE SUMMARY STATISTICS FOR HEIGHT WEIGHT,AND AGE OF THE GIVEN DATA
CADRE WISE*/
title1 color=black"TABLE6 SUMMARY STATISTICS TABLE FOR HEIGHT,WEIGHT AND AGE";

proc means data=faculty_sort nonobs ;
	var height__cm_ weight age;
	class cadre;
run;

title;
**************************************************************************************************;
*QUESTION 9*;

/*TO PRINT FACULTY INCOME AND EXPENDITURE ACCOUNT IN
INCREASING ORDER OF INCOME*/
*TO SORT THE DATA IN INCREASING ORDER OF ANNUAL INCOME*;

proc sort data=faculty_demographic out=faculty_income;
	by annual_income;
run;

*TO GENERATE OUTPUT TABLE*;
title color=black "TABLE7 FACULTY INCOME AND EXPENDITURE ACCOUNT";

proc print data=faculty_income;
	var name annual_income annual_expense savings;
run;

title;
************************************************************************************************;
*QUESTION 10*;
*/PLOTTING BAR GRAPH FOR ANNUAL SAVINGS*/;
ods graphics / reset width=6.4in height=4in imagemap;

proc sgplot data=WORK.FACULTY_SORT;
	title height=14pt "BAR CHART";
	footnote2 justify=CENTER height=15pt 
		"FIG-4 BAR GRAPH DEPICTING ANNUAL SAVINGS DATA";
	vbar savings / fillattrs=(color=CXf79e9e) dataskin=sheen;
	xaxis valuesrotate=vertical;
	yaxis max=8 grid label="number of faculties";
run;

ods graphics / reset;
title;
footnote2;
*****************************************************************************************
QUESTION 11;

/* TO PRINT FACULTY CONTACT INFORMATION DEPARTMENT WISE SORTED
IN DESCENDING OF CADRE*/
title1 color=black"TABLE8 FACULTY CONTACT INFORMATION";
title2 color=darkgreen  underlin=1"BIOTECHNOLOGY ENGINEERING";

proc print data=faculty_sort;
	where dept="BTE";
	var name mobile_no college_email_id personal_email_id;
run;

title;
title3 color=darkgreen underlin=1 "COMPUTER SCIENCE ENGINEERING";

proc print data=faculty_sort;
	where dept="CSE";
	var name mobile_no college_email_id personal_email_id;
run;

title;
title4 color=darkgreen underlin=1 "CIVIL ENGINEERING";

proc print data=faculty_sort;
	where dept="CVE";
	var name mobile_no college_email_id personal_email_id;
run;

title;
title5 color=darkgreen underlin=1  "ELECTRONICS AND COMM UNICATION ENGINEERING";

proc print data=faculty_sort;
	where dept="ECE";
	var name mobile_no college_email_id personal_email_id;
run;

title;
title6 color=darkgreen underlin=1 "MECHANICAL ENGINEERING";

proc print data=faculty_sort;
	where dept="MEC";
	var name mobile_no college_email_id personal_email_id;
run;

title;
******************************************************************************************;
*QUESTION 12 *;
*PLOTTING PIE CHART FOR MEANS OF TRANSPORT DEPARTMENT WISE*;

proc template;
	define statgraph SASStudio.Pie;
		begingraph;
		entrytitle "PIE CHART" / textattrs=(size=14);
		entryfootnote halign=CENTER "FIG.5 DEPARTMENT WISE FOR MEANS OF TRANSPORT" / 
			textattrs=(size=12);
		layout region;
		piechart category=means_of_transport / group=Dept groupgap=2% 
			datalabellocation=inside datalabelattrs=(size=8) dataskin=matte;
		endlayout;
		endgraph;
	end;
run;

ods graphics / reset width=6.4in height=4.5in imagemap;

proc sgrender template=SASStudio.Pie data=WORK.FACULTY_SORT;
run;

ods graphics / reset;
*************************************************************************************************************************;
*QUESTION 13*;
*PLOTTING LINE CHART FOR RESIDENCE DATA*;
ods graphics / reset width=5.4in height=4.5in imagemap;

proc sgplot data=WORK.FACULTY_SORT;
	title height=13pt "LINE CHART";
	footnote2 justify=CENTER height=12pt "FIG-6 RESIDENCE DATA";
	vline Residence / group=Gender datalabel lineattrs=(thickness=2);
	yaxis grid label="number of faculty";
run;

ods graphics / reset;
title;
footnote2;
*************************************************************************************************************************;
ods pdf close;
*************************************************************************************************************************;