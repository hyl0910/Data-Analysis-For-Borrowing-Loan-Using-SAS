data japan;
set MYSASLIB.japan_travellers;
*Anonymised full_name;
First=scan(full_name,1);
Last=scan(full_name,2);
First1=substr(First,2);
Last1=substr(Last,2);
First2=translate(First1,'xxxxxxxxxxxxxxxxxxxxxxxxxx','QWERTYUIOPASDFGHJKLZXCVBNM');
Last2=translate(Last1,'xxxxxxxxxxxxxxxxxxxxxxxxxx','QWERTYUIOPASDFGHJKLZXCVBNM');
FirstF=trim(substr(First,1,1)) !! First2;
LastF=trim(substr(Last,1,1)) !! Last2;
new_full_name=trim(FirstF)!! ' '!!LastF;
drop First Last First1 Last1 First2 Last2 FirstF LastF;

*Anonymised telephone;
new_telephone=trim(substr(telephone,1,4)) !! translate(substr(telephone,4,4),'xxxxxxxxxx','1234567890');

*Anonymised district;
orginal_district=district;
orginal_region=region;
area_no = floor(18*ranuni(33)+1);
set mysaslib.hk_districts point = area_no;
rename district=new_district;
rename region=new_region;
rename orginal_district=district;
rename orginal_region=region;

*Anonymised address;
fake_flat = 'A B C D E F G 1 2 3 4 5 6 7 8';
ran_number = Floor(15*ranuni(100)+1);
new_flat_no = 'flat ' !! scan(fake_flat, ran_number); 
fake_floor = '1 12 23 34 45 56 67 65 54 43 32 21';
ran_number2 = Floor(12*ranuni(100)+1);
new_floor_no = scan(fake_floor, ran_number2) !! '/F';
drop fake_flat ran_number fake_floor ran_number2;
new_address = trim(new_flat_no) !! ', ' !! trim(new_floor_no);

run;