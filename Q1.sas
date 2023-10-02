/* Group member list
   LAU Hei Yee          s197671
   CHAN Ka Lam          s198167
   CHOI Katarina Kai Ru s198179
   HO Yan Wa            s198184
   LAM Yuet Ying        s198193*/
/* Q1 */

/* Import data set */
proc import datafile= "loan_train.csv"
out=loan dbms = csv replace;
run;

/* Data cleaning */
DATA loan_cleaned ;
SET loan;
IF missing(Gender) THEN Gender=" ";
ELSE IF Gender="Male" THEN Gender="1";
ELSE Gender="0";


IF missing(Married) THEN Married=" ";
ELSE IF Married="Yes" THEN Married="1";
ELSE Married="0";


IF missing(Dependents) THEN Dependents=" ";
ELSE IF Dependents="3+" THEN Dependents="3";

IF Education="Graduate" THEN Education="0";
ELSE Education="1";

IF missing(Self_Employed) THEN Self_Employed=" ";
ELSE IF Self_Employed="Yes" THEN Self_Employed="1";
ELSE Self_Employed="0";

IF missing(Term) THEN Term=.;
IF missing(Credit_History) THEN Credit_History=" ";

IF Area="Urban" THEN Area="0";
ELSE IF Area="Rural" THEN Area="1";
ELSE Area="3";

IF Status="Y" THEN Status="1";
ELSE Status="0";

IF Loan_Amount="0" THEN delete;

/* Create new variable */
TotalIncome= Applicant_Income+Coapplicant_Income;
Debt_ratio= Loan_Amount/TotalIncome;

/* Convert character variable to numeric variable */
GenderN =INPUT(Gender,5.);
MarriedN =INPUT(Married,5.);
DependentsN =INPUT(Dependents,5.);
EducationN =INPUT(Education,5.);
Self_EmployedN =INPUT(Self_Employed,5.);
AreaN =INPUT(Area,5.);
StatusN =INPUT(Status,5.);

/* Drop unnecessary variables */
Drop Gender Married Dependents Education Self_Employed Area Status;

proc print data=loan_cleaned (obs=10);
run;

/* Data correlation */
PROC CORR DATA=loan_cleaned NOPROB;
VAR GenderN MarriedN DependentsN EducationN Self_EmployedN Applicant_Income Coapplicant_Income Term Credit_History TotalIncome Debt_ratio;
WITH Loan_Amount;

PROC CORR DATA=loan_cleaned NOPROB;
VAR GenderN MarriedN DependentsN EducationN Self_EmployedN Applicant_Income Coapplicant_Income Loan_Amount Term Credit_History TotalIncome Debt_ratio;
WITH StatusN;
RUN;

/* Regression */
/* Loan Amount (Multiple linear regression) */
/* Stepwise selection */
proc reg data=loan_cleaned;
model Loan_Amount = Applicant_Income Coapplicant_Income Term Credit_History	TotalIncome	Debt_ratio
					GenderN	MarriedN DependentsN EducationN	Self_EmployedN AreaN StatusN/ 
					selection=stepwise
					slstay=0.05; /* Adjust p value */
		title 'Stepwise selection of loan amount';
run;

/* Build the model */
proc reg data=loan_cleaned;
model Loan_Amount = TotalIncome	Debt_ratio MarriedN EducationN Self_EmployedN/p cli;
title 'Regression for loan amount';
run;

/* Status (Logistic regression) */
/* Stepwise selection */ 
proc logistic data=loan_cleaned;
model StatusN= Applicant_Income Coapplicant_Income Term Credit_History	TotalIncome Loan_Amount	Debt_ratio
			   GenderN MarriedN DependentsN EducationN	Self_EmployedN AreaN / 
			   selection=stepwise
			   slentry=0.05
			   slstay=0.01;
run;

/* Build the model */
proc logistic data=loan_cleaned;
model StatusN= Credit_History AreaN/ expb lackfit risklimits ctable outroc=roc1;
title 'Regression for status';
run;

/* Clustering */
/*amount and total income*/
proc standard data = mysaslib.loan_cleaned out = totalincomeAmount mean = 0 std = 1;
    var totalincome loan_amount;
run;

proc fastclus data = totalincomeAmount out = amount_cluster
maxclusters=3 maxiter =100;
var totalincome loan_amount;
run;

proc sgplot;
	scatter y = loan_amount x=totalincome / group = cluster;
	title 'Relationship between Total Income and Loan Amount';
run;

 /*amount and ratio*/
proc standard data = mysaslib.loan_cleaned out = ratioAmount mean = 0 std = 1;
    var debt_ratio loan_amount;
run;

proc fastclus data = ratioAmount out = amount_cluster
maxclusters=3 maxiter =100;
var debt_ratio loan_amount;
run;

proc sgplot;
	scatter y = loan_amount x=debt_ratio / group = cluster;
	title 'Relationship between Debit Ratio and Loan Amount';
run;
