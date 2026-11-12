-- SBA Day examination timetable, November 12-30, 2026.
-- Repeatable import: exam source keys prevent duplicates on subsequent runs.
INSERT IGNORE INTO course_units (code, name, school, degree_program, year_of_study, semester) VALUES
  ('SBA', 'Computer Applications I', 'SBA', 'DEG', 1, 1),
  ('SBA', 'Computer Applications I', 'SBA', 'DIP', 1, 1),
  ('SBA', 'Computer Applications II', 'SBA', 'DEG', 1, 1),
  ('SBA', 'Computer Applications II', 'SBA', 'DIP', 1, 1),
  ('SBA', 'Computerized Accounting I', 'SBA', 'DEG', 1, 1),
  ('SBA', 'Computerized Accounting I', 'SBA', 'DIP', 1, 1),
  ('SBA', 'Computer Skills', 'SBA', 'HCBM', 1, 1),
  ('SBA', 'Computerized Accounting II', 'SBA', 'DEG', 1, 1),
  ('SBA', 'Management of Eectronic Records', 'SBA', 'DIP', 1, 1),
  ('SBA', 'Public Private Partnership', 'SBA', 'DEG', 1, 1),
  ('SBA', 'Automation of Records System II', 'SBA', 'DEG', 1, 1),
  ('SBA', 'Introductory French', 'SBA', 'DEG', 1, 1),
  ('SBA', 'Introductory French', 'SBA', 'DIP', 1, 1),
  ('SBA', 'Introductory Kiswahili', 'SBA', 'DEG', 1, 1),
  ('SBA', 'Introductory Kiswahili', 'SBA', 'DIP', 1, 1),
  ('SBA', 'Introductory German', 'SBA', 'DEG', 1, 1),
  ('SBA', 'Introductory German', 'SBA', 'DIP', 1, 1),
  ('SBA', 'Personnel Management', 'SBA', 'DIP', 1, 1),
  ('SBA', 'Principles of Procurement and Supplies Mgt', 'SBA', 'HCBM', 1, 1),
  ('SBA', 'Competence Human Resource  Issues', 'SBA', 'DEG', 1, 1),
  ('SBA', 'Intermediate French', 'SBA', 'DEG', 1, 1),
  ('SBA', 'Intermediate French', 'SBA', 'DIP', 1, 1),
  ('SBA', 'Intermediate German', 'SBA', 'DEG', 1, 1),
  ('SBA', 'Intermediate German', 'SBA', 'DIP', 1, 1),
  ('SBA', 'Intermediate Kiswahili', 'SBA', 'DEG', 1, 1),
  ('SBA', 'Intermediate Kiswahili', 'SBA', 'DIP', 1, 1),
  ('SBA', 'Quantitative Methods', 'SBA', 'DEG', 1, 1),
  ('SBA', 'Auditing I', 'SBA', 'DEG', 1, 1),
  ('SBA', 'Auditing I', 'SBA', 'DIP', 1, 1),
  ('SBA', 'Marketing Research', 'SBA', 'DEG', 1, 1),
  ('SBA', 'Principles of Clearing and Forwarding Management', 'SBA', 'DEG', 1, 1),
  ('SBA', 'Comparative Business Analysis', 'SBA', 'DEG', 1, 1),
  ('SBA', 'Communication skills for Records Managers', 'SBA', 'DEG', 1, 1),
  ('SBA', 'Communication skills for Records Managers', 'SBA', 'DIP', 1, 1),
  ('SBA', 'Advanced French', 'SBA', 'DEG', 1, 1),
  ('SBA', 'Advanced French', 'SBA', 'DIP', 1, 1),
  ('SBA', 'Advanced Kiswahili', 'SBA', 'DEG', 1, 1),
  ('SBA', 'Advanced Kiswahili', 'SBA', 'DIP', 1, 1),
  ('SBA', 'Advanced German', 'SBA', 'DEG', 1, 1),
  ('SBA', 'Advanced German', 'SBA', 'DIP', 1, 1),
  ('SBA', 'Laundry Operations', 'SBA', 'DEG', 1, 1),
  ('SBA', 'Financial Management/Business Finance 1', 'SBA', 'DEG', 1, 1),
  ('SBA', 'Financial Management/Business Finance 1', 'SBA', 'DIP', 1, 1),
  ('SBA', 'Management of Information Systems', 'SBA', 'DEG', 1, 1),
  ('SBA', 'Management of Information Systems', 'SBA', 'DIP', 1, 1),
  ('SBA', 'International Financial Markets & Banking', 'SBA', 'DEG', 1, 1),
  ('SBA', 'Procurement Contracts Management', 'SBA', 'DEG', 1, 1),
  ('SBA', 'Medical Records Management', 'SBA', 'DEG', 1, 1),
  ('SBA', 'Library Cataloguing: theory and Practice', 'SBA', 'DIP', 1, 1),
  ('SBA', 'Sustainable Procurement', 'SBA', 'DEG', 1, 1),
  ('SBA', 'Principles of Tourism Management', 'SBA', 'DEG', 1, 1),
  ('SBA', 'Taxation Management', 'SBA', 'DEG', 1, 1),
  ('SBA', 'Taxation Management', 'SBA', 'DIP', 1, 1),
  ('SBA', 'Auditing II', 'SBA', 'DEG', 1, 1),
  ('SBA', 'International Trade Law', 'SBA', 'DEG', 1, 1),
  ('SBA', 'Procurement and Stores Management', 'SBA', 'DIP', 1, 1),
  ('SBA', 'Foundation of Mathematics', 'SBA', 'HCBM', 1, 1),
  ('SBA', 'Housekeeping', 'SBA', 'DEG', 1, 1),
  ('SBA', 'Housekeeping', 'SBA', 'DIP', 1, 1),
  ('SBA', 'Human Resource Planning', 'SBA', 'DEG', 1, 1),
  ('SBA', 'Reward Strategy and Management', 'SBA', 'DEG', 1, 1),
  ('SBA', 'Museum Management', 'SBA', 'DEG', 1, 1),
  ('SBA', 'Sales and Sales Force Management', 'SBA', 'DIP', 1, 1),
  ('SBA', 'Introduction to Marketing', 'SBA', 'HCBM', 1, 1),
  ('SBA', 'Entrepreneurship', 'SBA', 'DEG', 1, 1),
  ('SBA', 'Entrepreneurship', 'SBA', 'DIP', 1, 1),
  ('SBA', 'Principles of Procurement and Logistics Mgt', 'SBA', 'DEG', 1, 1),
  ('SBA', 'Economics I', 'SBA', 'DEG', 1, 1),
  ('SBA', 'Economics I', 'SBA', 'DIP', 1, 1),
  ('SBA', 'Import and Export Management', 'SBA', 'DEG', 1, 1),
  ('SBA', 'Retail Marketing', 'SBA', 'DEG', 1, 1),
  ('SBA', 'Customer Care', 'SBA', 'DEG', 1, 1),
  ('SBA', 'Customer Care', 'SBA', 'DIP', 1, 1),
  ('SBA', 'Intermediate Accounting', 'SBA', 'DEG', 1, 1),
  ('SBA', 'Intermediate Accounting', 'SBA', 'DIP', 1, 1),
  ('SBA', 'Public Sector Procurement', 'SBA', 'DEG', 1, 1),
  ('SBA', 'Economics Il', 'SBA', 'DEG', 1, 1),
  ('SBA', 'Economics Il', 'SBA', 'DIP', 1, 1),
  ('SBA', 'Dangerous Cargo Management', 'SBA', 'DEG', 1, 1),
  ('SBA', 'Records Preservation and Conservation', 'SBA', 'DEG', 1, 1),
  ('SBA', 'Records Preservation and Conservation', 'SBA', 'DIP', 1, 1),
  ('SBA', 'E-Procurement', 'SBA', 'DEG', 1, 1),
  ('SBA', 'Labour Economics', 'SBA', 'DEG', 1, 1),
  ('SBA', 'Labour Economics', 'SBA', 'DIP', 1, 1),
  ('SBA', 'International Human Resource Mgt', 'SBA', 'DEG', 1, 1),
  ('SBA', 'Customs Declaration and Tariffs', 'SBA', 'DEG', 1, 1),
  ('SBA', 'Business Policy', 'SBA', 'DIP', 1, 1),
  ('SBA', 'Communication Skills', 'SBA', 'HCBM', 1, 1),
  ('SBA', 'Health and Hygiene/Food hygiene and Safety', 'SBA', 'DEG', 1, 1),
  ('SBA', 'Health and Hygiene/Food hygiene and Safety', 'SBA', 'DIP', 1, 1),
  ('SBA', 'Tourism Product Development', 'SBA', 'DEG', 1, 1),
  ('SBA', 'Operations Research', 'SBA', 'DEG', 1, 1),
  ('SBA', 'Employee Relations', 'SBA', 'DEG', 1, 1),
  ('SBA', 'Small Business Management', 'SBA', 'DIP', 1, 1),
  ('SBA', 'User Services and user Relations', 'SBA', 'DIP', 1, 1),
  ('SBA', 'Entrepreneurship and Small Business', 'SBA', 'HCBM', 1, 1),
  ('SBA', 'Purchasing & Supplies Management', 'SBA', 'DIP', 1, 1),
  ('SBA', 'Business Ethics', 'SBA', 'DEG', 1, 1),
  ('SBA', 'Business Ethics', 'SBA', 'DIP', 1, 1),
  ('SBA', 'Customer Service Management', 'SBA', 'DEG', 1, 1),
  ('SBA', 'Procurement Negotiation Management', 'SBA', 'DEG', 1, 1),
  ('SBA', 'Workplace Counselling/Employee Counselling', 'SBA', 'DEG', 1, 1),
  ('SBA', 'Fundamentals of Procurement Management', 'SBA', 'DEG', 1, 1),
  ('SBA', 'Insurance Management', 'SBA', 'DEG', 1, 1),
  ('SBA', 'Office Records Management', 'SBA', 'DIP', 1, 1),
  ('SBA', 'Systems Analysis & Design', 'SBA', 'DEG', 1, 1),
  ('SBA', 'Banking & Insurance Laws', 'SBA', 'DEG', 1, 1),
  ('SBA', 'Human Resource Management in the Supply Chain', 'SBA', 'DEG', 1, 1),
  ('SBA', 'Ethics in Human Resource Mgt', 'SBA', 'DEG', 1, 1),
  ('SBA', 'Economics of Sea Transport Management', 'SBA', 'DEG', 1, 1),
  ('SBA', 'Archives Administration and Management', 'SBA', 'DEG', 1, 1),
  ('SBA', 'Archives Administration and Management', 'SBA', 'DIP', 1, 1),
  ('SBA', 'Procurement Ethics Audit & Investigation', 'SBA', 'DEG', 1, 1),
  ('SBA', 'Management Accounting', 'SBA', 'DEG', 1, 1),
  ('SBA', 'Logistics and Procurement Communication', 'SBA', 'DEG', 1, 1),
  ('SBA', 'Human Resource Training', 'SBA', 'DEG', 1, 1),
  ('SBA', 'Community Information Services', 'SBA', 'DEG', 1, 1),
  ('SBA', 'Introduction to Development Studies', 'SBA', 'HCBM', 1, 1),
  ('SBA', 'Organisation Staffing & Management', 'SBA', 'DEG', 1, 1),
  ('SBA', 'Food Service Operations', 'SBA', 'DEG', 1, 1),
  ('SBA', 'Food Service Operations', 'SBA', 'DIP', 1, 1),
  ('SBA', 'Human Resource Management', 'SBA', 'DEG', 1, 1),
  ('SBA', 'Procurement Law', 'SBA', 'DEG', 1, 1),
  ('SBA', 'H.R Management Information Systems', 'SBA', 'DEG', 1, 1),
  ('SBA', 'Logistics and Distribution Management', 'SBA', 'DEG', 1, 1),
  ('SBA', 'Compliance and Regulatory Environ in RIM', 'SBA', 'DIP', 1, 1),
  ('SBA', 'Introduction to Human Resource Management', 'SBA', 'HCBM', 1, 1),
  ('SBA', 'Fundamentals of Tourism', 'SBA', 'DEG', 1, 1),
  ('SBA', 'Fundamentals of Tourism', 'SBA', 'DIP', 1, 1),
  ('SBA', 'Cost Accounting', 'SBA', 'DEG', 1, 1),
  ('SBA', 'Cost Accounting', 'SBA', 'DIP', 1, 1),
  ('SBA', 'International Marketing', 'SBA', 'DEG', 1, 1),
  ('SBA', 'Warehousing and Inventory Management', 'SBA', 'DEG', 1, 1),
  ('SBA', 'Shipping Principles and Practices', 'SBA', 'DEG', 1, 1),
  ('SBA', 'Information Sources, Systems and Services', 'SBA', 'DEG', 1, 1),
  ('SBA', 'Food Service Equipment and Design', 'SBA', 'DEG', 1, 1),
  ('SBA', 'Money, Banking and Insurance', 'SBA', 'DEG', 1, 1),
  ('SBA', 'Money, Banking and Insurance', 'SBA', 'DIP', 1, 1),
  ('SBA', 'Life and General Insurance', 'SBA', 'DEG', 1, 1),
  ('SBA', 'Strategic Procurement Management', 'SBA', 'DEG', 1, 1),
  ('SBA', 'Clearing and Forwading Law', 'SBA', 'DEG', 1, 1),
  ('SBA', 'Management Information Systems', 'SBA', 'DEG', 1, 1),
  ('SBA', 'Management Information Systems', 'SBA', 'DIP', 1, 1),
  ('SBA', 'Managing Supplier Relations in Procurement', 'SBA', 'DEG', 1, 1),
  ('SBA', 'Fundamentals of Accounting', 'SBA', 'DEG', 1, 1),
  ('SBA', 'Fundamentals of Accounting', 'SBA', 'DIP', 1, 1),
  ('SBA', 'Comparative Business Management', 'SBA', 'DEG', 1, 1),
  ('SBA', 'Investment Analysis', 'SBA', 'DEG', 1, 1),
  ('SBA', 'Information Institutions and Resources', 'SBA', 'DIP', 1, 1),
  ('SBA', 'Principles of Management', 'SBA', 'HCBM', 1, 1),
  ('SBA', 'Introduction to Food and Nutrition', 'SBA', 'DEG', 1, 1),
  ('SBA', 'Introduction to Food and Nutrition', 'SBA', 'DIP', 1, 1),
  ('SBA', 'Food Production and Presentation', 'SBA', 'DEG', 1, 1),
  ('SBA', 'Food Production and Presentation', 'SBA', 'DIP', 1, 1),
  ('SBA', 'Advanced Accounting I', 'SBA', 'DEG', 1, 1),
  ('SBA', 'Advanced Accounting I', 'SBA', 'DIP', 1, 1),
  ('SBA', 'Procurement of Works Services and Systems', 'SBA', 'DEG', 1, 1),
  ('SBA', 'E-Clearing and Forwading', 'SBA', 'DEG', 1, 1),
  ('SBA', 'Information Entrepreneurship', 'SBA', 'DEG', 1, 1),
  ('SBA', 'Fundamentals of Business Information Systems', 'SBA', 'HCBM', 1, 1),
  ('SBA', 'Elements of Business Finance', 'SBA', 'NBCA', 1, 1),
  ('SBA', 'Human Resource  Competence Mapping', 'SBA', 'DEG', 1, 1),
  ('SBA', 'Wildlife and Protected Area Management', 'SBA', 'DEG', 1, 1),
  ('SBA', 'Business Startistics II', 'SBA', 'DEG', 1, 1),
  ('SBA', 'Marketing of Farm Produce', 'SBA', 'DEG', 1, 1),
  ('SBA', 'Fleet and Transport Management', 'SBA', 'DEG', 1, 1),
  ('SBA', 'Research Methods', 'SBA', 'DEG', 1, 1),
  ('SBA', 'International Taxation', 'SBA', 'DEG', 1, 1),
  ('SBA', 'Foundations of Records Management', 'SBA', 'DEG', 1, 1),
  ('SBA', 'Foundations of Records Management', 'SBA', 'DIP', 1, 1),
  ('SBA', 'East Africa Flora Ecology', 'SBA', 'DEG', 1, 1),
  ('SBA', 'East Africa Flora Ecology', 'SBA', 'DIP', 1, 1),
  ('SBA', 'Industrial Relations', 'SBA', 'DEG', 1, 1),
  ('SBA', 'Industrial Relations', 'SBA', 'DIP', 1, 1),
  ('SBA', 'Risk and Insurance', 'SBA', 'DEG', 1, 1),
  ('SBA', 'Supply Chain Management Practice', 'SBA', 'DEG', 1, 1),
  ('SBA', 'Performance Mgt and Assessment', 'SBA', 'DEG', 1, 1),
  ('SBA', 'Disposal Management', 'SBA', 'DEG', 1, 1),
  ('SBA', 'Tourism and Hospitality Services Management', 'SBA', 'DEG', 1, 1),
  ('SBA', 'Public Relations', 'SBA', 'DEG', 1, 1),
  ('SBA', 'Public Relations', 'SBA', 'DIP', 1, 1),
  ('SBA', 'Advanced Accounting II', 'SBA', 'DEG', 1, 1),
  ('SBA', 'Business Communication', 'SBA', 'DEG', 1, 1),
  ('SBA', 'Business Communication', 'SBA', 'DIP', 1, 1),
  ('SBA', 'Information Technology', 'SBA', 'DEG', 1, 1),
  ('SBA', 'Database Management Systems', 'SBA', 'DEG', 1, 1),
  ('SBA', 'Mgt of Registries and Records Centers', 'SBA', 'DIP', 1, 1),
  ('SBA', 'Introduction to Business Law', 'SBA', 'HCBM', 1, 1),
  ('SBA', 'Food Preparation Principles II/Food Theory II', 'SBA', 'DEG', 1, 1),
  ('SBA', 'Food Preparation Principles II/Food Theory II', 'SBA', 'DIP', 1, 1),
  ('SBA', 'Business Finance II', 'SBA', 'DEG', 1, 1),
  ('SBA', 'Auditing and Computerised Accounting', 'SBA', 'DEG', 1, 1),
  ('SBA', 'Risk Management', 'SBA', 'DEG', 1, 1),
  ('SBA', 'Regional Integration and Tax Issues', 'SBA', 'DEG', 1, 1),
  ('SBA', 'Office Management', 'SBA', 'DIP', 1, 1),
  ('SBA', 'Introduction to Economics', 'SBA', 'HCBM', 1, 1),
  ('SBA', 'Project Planning & Management', 'SBA', 'DEG', 1, 1),
  ('SBA', 'Tourism Business Law', 'SBA', 'DEG', 1, 1);

INSERT IGNORE INTO exams
  (course_unit_id, exam_date, start_time, end_time, room, program, school,
   source_sheet, source_row, source_column, source_date_label, source_text)
SELECT cu.id, '2026-11-12', '09:00:00', '12:00:00', 'NOT SPECIFIED', 'DAY', 'SBA', 'SBA Day Timetable', 1, 2, 'THURSDAY 12TH NOVEMBER', 'Computer Applications I (DEG)' FROM course_units cu WHERE cu.code = 'SBA' AND cu.name = 'Computer Applications I' AND cu.school = 'SBA' AND cu.degree_program = 'DEG' AND cu.year_of_study = 1 AND cu.semester = 1
UNION ALL
SELECT cu.id, '2026-11-12', '09:00:00', '12:00:00', 'NOT SPECIFIED', 'DAY', 'SBA', 'SBA Day Timetable', 2, 2, 'THURSDAY 12TH NOVEMBER', 'Computer Applications I (DIP)' FROM course_units cu WHERE cu.code = 'SBA' AND cu.name = 'Computer Applications I' AND cu.school = 'SBA' AND cu.degree_program = 'DIP' AND cu.year_of_study = 1 AND cu.semester = 1
UNION ALL
SELECT cu.id, '2026-11-13', '09:00:00', '12:00:00', 'NOT SPECIFIED', 'DAY', 'SBA', 'SBA Day Timetable', 3, 2, 'FRIDAY 13TH NOVEMBER', 'Computer Applications II (DEG)' FROM course_units cu WHERE cu.code = 'SBA' AND cu.name = 'Computer Applications II' AND cu.school = 'SBA' AND cu.degree_program = 'DEG' AND cu.year_of_study = 1 AND cu.semester = 1
UNION ALL
SELECT cu.id, '2026-11-13', '09:00:00', '12:00:00', 'NOT SPECIFIED', 'DAY', 'SBA', 'SBA Day Timetable', 4, 2, 'FRIDAY 13TH NOVEMBER', 'Computer Applications II (DIP)' FROM course_units cu WHERE cu.code = 'SBA' AND cu.name = 'Computer Applications II' AND cu.school = 'SBA' AND cu.degree_program = 'DIP' AND cu.year_of_study = 1 AND cu.semester = 1
UNION ALL
SELECT cu.id, '2026-11-14', '09:00:00', '12:00:00', 'NOT SPECIFIED', 'DAY', 'SBA', 'SBA Day Timetable', 5, 2, 'SATURDAY 14TH NOVEMBER', 'Computerized Accounting I (DEG)' FROM course_units cu WHERE cu.code = 'SBA' AND cu.name = 'Computerized Accounting I' AND cu.school = 'SBA' AND cu.degree_program = 'DEG' AND cu.year_of_study = 1 AND cu.semester = 1
UNION ALL
SELECT cu.id, '2026-11-14', '09:00:00', '12:00:00', 'NOT SPECIFIED', 'DAY', 'SBA', 'SBA Day Timetable', 6, 2, 'SATURDAY 14TH NOVEMBER', 'Computerized Accounting I (DIP)' FROM course_units cu WHERE cu.code = 'SBA' AND cu.name = 'Computerized Accounting I' AND cu.school = 'SBA' AND cu.degree_program = 'DIP' AND cu.year_of_study = 1 AND cu.semester = 1
UNION ALL
SELECT cu.id, '2026-11-14', '09:00:00', '12:00:00', 'NOT SPECIFIED', 'DAY', 'SBA', 'SBA Day Timetable', 7, 2, 'SATURDAY 14TH NOVEMBER', 'Computer Skills (HCBM)' FROM course_units cu WHERE cu.code = 'SBA' AND cu.name = 'Computer Skills' AND cu.school = 'SBA' AND cu.degree_program = 'HCBM' AND cu.year_of_study = 1 AND cu.semester = 1
UNION ALL
SELECT cu.id, '2026-11-15', '09:00:00', '12:00:00', 'NOT SPECIFIED', 'DAY', 'SBA', 'SBA Day Timetable', 8, 2, 'SUNDAY 15TH NOVEMBER', 'Computerized Accounting II (DEG)' FROM course_units cu WHERE cu.code = 'SBA' AND cu.name = 'Computerized Accounting II' AND cu.school = 'SBA' AND cu.degree_program = 'DEG' AND cu.year_of_study = 1 AND cu.semester = 1
UNION ALL
SELECT cu.id, '2026-11-15', '14:00:00', '17:00:00', 'NOT SPECIFIED', 'DAY', 'SBA', 'SBA Day Timetable', 9, 4, 'SUNDAY 15TH NOVEMBER', 'Management of Eectronic Records (DIP)' FROM course_units cu WHERE cu.code = 'SBA' AND cu.name = 'Management of Eectronic Records' AND cu.school = 'SBA' AND cu.degree_program = 'DIP' AND cu.year_of_study = 1 AND cu.semester = 1
UNION ALL
SELECT cu.id, '2026-11-16', '09:00:00', '12:00:00', 'NOT SPECIFIED', 'DAY', 'SBA', 'SBA Day Timetable', 10, 2, 'MONDAY 16TH NOVEMBER', 'Public Private Partnership (DEG)' FROM course_units cu WHERE cu.code = 'SBA' AND cu.name = 'Public Private Partnership' AND cu.school = 'SBA' AND cu.degree_program = 'DEG' AND cu.year_of_study = 1 AND cu.semester = 1
UNION ALL
SELECT cu.id, '2026-11-16', '09:00:00', '12:00:00', 'NOT SPECIFIED', 'DAY', 'SBA', 'SBA Day Timetable', 11, 2, 'MONDAY 16TH NOVEMBER', 'Automation of Records System II (DEG)' FROM course_units cu WHERE cu.code = 'SBA' AND cu.name = 'Automation of Records System II' AND cu.school = 'SBA' AND cu.degree_program = 'DEG' AND cu.year_of_study = 1 AND cu.semester = 1
UNION ALL
SELECT cu.id, '2026-11-16', '09:00:00', '12:00:00', 'NOT SPECIFIED', 'DAY', 'SBA', 'SBA Day Timetable', 12, 2, 'MONDAY 16TH NOVEMBER', 'Introductory French (DEG)' FROM course_units cu WHERE cu.code = 'SBA' AND cu.name = 'Introductory French' AND cu.school = 'SBA' AND cu.degree_program = 'DEG' AND cu.year_of_study = 1 AND cu.semester = 1
UNION ALL
SELECT cu.id, '2026-11-16', '09:00:00', '12:00:00', 'NOT SPECIFIED', 'DAY', 'SBA', 'SBA Day Timetable', 13, 2, 'MONDAY 16TH NOVEMBER', 'Introductory French (DIP)' FROM course_units cu WHERE cu.code = 'SBA' AND cu.name = 'Introductory French' AND cu.school = 'SBA' AND cu.degree_program = 'DIP' AND cu.year_of_study = 1 AND cu.semester = 1
UNION ALL
SELECT cu.id, '2026-11-16', '09:00:00', '12:00:00', 'NOT SPECIFIED', 'DAY', 'SBA', 'SBA Day Timetable', 14, 2, 'MONDAY 16TH NOVEMBER', 'Introductory Kiswahili (DEG)' FROM course_units cu WHERE cu.code = 'SBA' AND cu.name = 'Introductory Kiswahili' AND cu.school = 'SBA' AND cu.degree_program = 'DEG' AND cu.year_of_study = 1 AND cu.semester = 1
UNION ALL
SELECT cu.id, '2026-11-16', '09:00:00', '12:00:00', 'NOT SPECIFIED', 'DAY', 'SBA', 'SBA Day Timetable', 15, 2, 'MONDAY 16TH NOVEMBER', 'Introductory Kiswahili (DIP)' FROM course_units cu WHERE cu.code = 'SBA' AND cu.name = 'Introductory Kiswahili' AND cu.school = 'SBA' AND cu.degree_program = 'DIP' AND cu.year_of_study = 1 AND cu.semester = 1
UNION ALL
SELECT cu.id, '2026-11-16', '09:00:00', '12:00:00', 'NOT SPECIFIED', 'DAY', 'SBA', 'SBA Day Timetable', 16, 2, 'MONDAY 16TH NOVEMBER', 'Introductory German (DEG)' FROM course_units cu WHERE cu.code = 'SBA' AND cu.name = 'Introductory German' AND cu.school = 'SBA' AND cu.degree_program = 'DEG' AND cu.year_of_study = 1 AND cu.semester = 1
UNION ALL
SELECT cu.id, '2026-11-16', '09:00:00', '12:00:00', 'NOT SPECIFIED', 'DAY', 'SBA', 'SBA Day Timetable', 17, 2, 'MONDAY 16TH NOVEMBER', 'Introductory German (DIP)' FROM course_units cu WHERE cu.code = 'SBA' AND cu.name = 'Introductory German' AND cu.school = 'SBA' AND cu.degree_program = 'DIP' AND cu.year_of_study = 1 AND cu.semester = 1
UNION ALL
SELECT cu.id, '2026-11-16', '14:00:00', '17:00:00', 'NOT SPECIFIED', 'DAY', 'SBA', 'SBA Day Timetable', 18, 4, 'MONDAY 16TH NOVEMBER', 'Personnel Management (DIP)' FROM course_units cu WHERE cu.code = 'SBA' AND cu.name = 'Personnel Management' AND cu.school = 'SBA' AND cu.degree_program = 'DIP' AND cu.year_of_study = 1 AND cu.semester = 1
UNION ALL
SELECT cu.id, '2026-11-16', '14:00:00', '17:00:00', 'NOT SPECIFIED', 'DAY', 'SBA', 'SBA Day Timetable', 19, 4, 'MONDAY 16TH NOVEMBER', 'Principles of Procurement and Supplies Mgt (HCBM)' FROM course_units cu WHERE cu.code = 'SBA' AND cu.name = 'Principles of Procurement and Supplies Mgt' AND cu.school = 'SBA' AND cu.degree_program = 'HCBM' AND cu.year_of_study = 1 AND cu.semester = 1
UNION ALL
SELECT cu.id, '2026-11-16', '14:00:00', '17:00:00', 'NOT SPECIFIED', 'DAY', 'SBA', 'SBA Day Timetable', 20, 4, 'MONDAY 16TH NOVEMBER', 'Competence Human Resource  Issues (DEG)' FROM course_units cu WHERE cu.code = 'SBA' AND cu.name = 'Competence Human Resource  Issues' AND cu.school = 'SBA' AND cu.degree_program = 'DEG' AND cu.year_of_study = 1 AND cu.semester = 1
UNION ALL
SELECT cu.id, '2026-11-16', '14:00:00', '17:00:00', 'NOT SPECIFIED', 'DAY', 'SBA', 'SBA Day Timetable', 21, 4, 'MONDAY 16TH NOVEMBER', 'Intermediate French (DEG)' FROM course_units cu WHERE cu.code = 'SBA' AND cu.name = 'Intermediate French' AND cu.school = 'SBA' AND cu.degree_program = 'DEG' AND cu.year_of_study = 1 AND cu.semester = 1
UNION ALL
SELECT cu.id, '2026-11-16', '14:00:00', '17:00:00', 'NOT SPECIFIED', 'DAY', 'SBA', 'SBA Day Timetable', 22, 4, 'MONDAY 16TH NOVEMBER', 'Intermediate French (DIP)' FROM course_units cu WHERE cu.code = 'SBA' AND cu.name = 'Intermediate French' AND cu.school = 'SBA' AND cu.degree_program = 'DIP' AND cu.year_of_study = 1 AND cu.semester = 1
UNION ALL
SELECT cu.id, '2026-11-16', '14:00:00', '17:00:00', 'NOT SPECIFIED', 'DAY', 'SBA', 'SBA Day Timetable', 23, 4, 'MONDAY 16TH NOVEMBER', 'Intermediate German (DEG)' FROM course_units cu WHERE cu.code = 'SBA' AND cu.name = 'Intermediate German' AND cu.school = 'SBA' AND cu.degree_program = 'DEG' AND cu.year_of_study = 1 AND cu.semester = 1
UNION ALL
SELECT cu.id, '2026-11-16', '14:00:00', '17:00:00', 'NOT SPECIFIED', 'DAY', 'SBA', 'SBA Day Timetable', 24, 4, 'MONDAY 16TH NOVEMBER', 'Intermediate German (DIP)' FROM course_units cu WHERE cu.code = 'SBA' AND cu.name = 'Intermediate German' AND cu.school = 'SBA' AND cu.degree_program = 'DIP' AND cu.year_of_study = 1 AND cu.semester = 1
UNION ALL
SELECT cu.id, '2026-11-16', '14:00:00', '17:00:00', 'NOT SPECIFIED', 'DAY', 'SBA', 'SBA Day Timetable', 25, 4, 'MONDAY 16TH NOVEMBER', 'Intermediate Kiswahili (DEG)' FROM course_units cu WHERE cu.code = 'SBA' AND cu.name = 'Intermediate Kiswahili' AND cu.school = 'SBA' AND cu.degree_program = 'DEG' AND cu.year_of_study = 1 AND cu.semester = 1
UNION ALL
SELECT cu.id, '2026-11-16', '14:00:00', '17:00:00', 'NOT SPECIFIED', 'DAY', 'SBA', 'SBA Day Timetable', 26, 4, 'MONDAY 16TH NOVEMBER', 'Intermediate Kiswahili (DIP)' FROM course_units cu WHERE cu.code = 'SBA' AND cu.name = 'Intermediate Kiswahili' AND cu.school = 'SBA' AND cu.degree_program = 'DIP' AND cu.year_of_study = 1 AND cu.semester = 1
UNION ALL
SELECT cu.id, '2026-11-17', '09:00:00', '12:00:00', 'NOT SPECIFIED', 'DAY', 'SBA', 'SBA Day Timetable', 27, 2, 'TUESDAY 17TH NOVEMBER', 'Quantitative Methods (DEG)' FROM course_units cu WHERE cu.code = 'SBA' AND cu.name = 'Quantitative Methods' AND cu.school = 'SBA' AND cu.degree_program = 'DEG' AND cu.year_of_study = 1 AND cu.semester = 1
UNION ALL
SELECT cu.id, '2026-11-17', '09:00:00', '12:00:00', 'NOT SPECIFIED', 'DAY', 'SBA', 'SBA Day Timetable', 28, 2, 'TUESDAY 17TH NOVEMBER', 'Auditing I (DEG)' FROM course_units cu WHERE cu.code = 'SBA' AND cu.name = 'Auditing I' AND cu.school = 'SBA' AND cu.degree_program = 'DEG' AND cu.year_of_study = 1 AND cu.semester = 1
UNION ALL
SELECT cu.id, '2026-11-17', '09:00:00', '12:00:00', 'NOT SPECIFIED', 'DAY', 'SBA', 'SBA Day Timetable', 29, 2, 'TUESDAY 17TH NOVEMBER', 'Auditing I (DIP)' FROM course_units cu WHERE cu.code = 'SBA' AND cu.name = 'Auditing I' AND cu.school = 'SBA' AND cu.degree_program = 'DIP' AND cu.year_of_study = 1 AND cu.semester = 1
UNION ALL
SELECT cu.id, '2026-11-17', '09:00:00', '12:00:00', 'NOT SPECIFIED', 'DAY', 'SBA', 'SBA Day Timetable', 30, 2, 'TUESDAY 17TH NOVEMBER', 'Marketing Research (DEG)' FROM course_units cu WHERE cu.code = 'SBA' AND cu.name = 'Marketing Research' AND cu.school = 'SBA' AND cu.degree_program = 'DEG' AND cu.year_of_study = 1 AND cu.semester = 1
UNION ALL
SELECT cu.id, '2026-11-17', '09:00:00', '12:00:00', 'NOT SPECIFIED', 'DAY', 'SBA', 'SBA Day Timetable', 31, 2, 'TUESDAY 17TH NOVEMBER', 'Principles of Clearing and Forwarding Management (DEG)' FROM course_units cu WHERE cu.code = 'SBA' AND cu.name = 'Principles of Clearing and Forwarding Management' AND cu.school = 'SBA' AND cu.degree_program = 'DEG' AND cu.year_of_study = 1 AND cu.semester = 1
UNION ALL
SELECT cu.id, '2026-11-17', '09:00:00', '12:00:00', 'NOT SPECIFIED', 'DAY', 'SBA', 'SBA Day Timetable', 32, 2, 'TUESDAY 17TH NOVEMBER', 'Comparative Business Analysis (DEG)' FROM course_units cu WHERE cu.code = 'SBA' AND cu.name = 'Comparative Business Analysis' AND cu.school = 'SBA' AND cu.degree_program = 'DEG' AND cu.year_of_study = 1 AND cu.semester = 1
UNION ALL
SELECT cu.id, '2026-11-17', '09:00:00', '12:00:00', 'NOT SPECIFIED', 'DAY', 'SBA', 'SBA Day Timetable', 33, 2, 'TUESDAY 17TH NOVEMBER', 'Communication skills for Records Managers (DEG)' FROM course_units cu WHERE cu.code = 'SBA' AND cu.name = 'Communication skills for Records Managers' AND cu.school = 'SBA' AND cu.degree_program = 'DEG' AND cu.year_of_study = 1 AND cu.semester = 1
UNION ALL
SELECT cu.id, '2026-11-17', '09:00:00', '12:00:00', 'NOT SPECIFIED', 'DAY', 'SBA', 'SBA Day Timetable', 34, 2, 'TUESDAY 17TH NOVEMBER', 'Communication skills for Records Managers (DIP)' FROM course_units cu WHERE cu.code = 'SBA' AND cu.name = 'Communication skills for Records Managers' AND cu.school = 'SBA' AND cu.degree_program = 'DIP' AND cu.year_of_study = 1 AND cu.semester = 1
UNION ALL
SELECT cu.id, '2026-11-17', '09:00:00', '12:00:00', 'NOT SPECIFIED', 'DAY', 'SBA', 'SBA Day Timetable', 35, 2, 'TUESDAY 17TH NOVEMBER', 'Advanced French (DEG)' FROM course_units cu WHERE cu.code = 'SBA' AND cu.name = 'Advanced French' AND cu.school = 'SBA' AND cu.degree_program = 'DEG' AND cu.year_of_study = 1 AND cu.semester = 1
UNION ALL
SELECT cu.id, '2026-11-17', '09:00:00', '12:00:00', 'NOT SPECIFIED', 'DAY', 'SBA', 'SBA Day Timetable', 36, 2, 'TUESDAY 17TH NOVEMBER', 'Advanced French (DIP)' FROM course_units cu WHERE cu.code = 'SBA' AND cu.name = 'Advanced French' AND cu.school = 'SBA' AND cu.degree_program = 'DIP' AND cu.year_of_study = 1 AND cu.semester = 1
UNION ALL
SELECT cu.id, '2026-11-17', '09:00:00', '12:00:00', 'NOT SPECIFIED', 'DAY', 'SBA', 'SBA Day Timetable', 37, 2, 'TUESDAY 17TH NOVEMBER', 'Advanced Kiswahili (DEG)' FROM course_units cu WHERE cu.code = 'SBA' AND cu.name = 'Advanced Kiswahili' AND cu.school = 'SBA' AND cu.degree_program = 'DEG' AND cu.year_of_study = 1 AND cu.semester = 1
UNION ALL
SELECT cu.id, '2026-11-17', '09:00:00', '12:00:00', 'NOT SPECIFIED', 'DAY', 'SBA', 'SBA Day Timetable', 38, 2, 'TUESDAY 17TH NOVEMBER', 'Advanced Kiswahili (DIP)' FROM course_units cu WHERE cu.code = 'SBA' AND cu.name = 'Advanced Kiswahili' AND cu.school = 'SBA' AND cu.degree_program = 'DIP' AND cu.year_of_study = 1 AND cu.semester = 1
UNION ALL
SELECT cu.id, '2026-11-17', '09:00:00', '12:00:00', 'NOT SPECIFIED', 'DAY', 'SBA', 'SBA Day Timetable', 39, 2, 'TUESDAY 17TH NOVEMBER', 'Advanced German (DEG)' FROM course_units cu WHERE cu.code = 'SBA' AND cu.name = 'Advanced German' AND cu.school = 'SBA' AND cu.degree_program = 'DEG' AND cu.year_of_study = 1 AND cu.semester = 1
UNION ALL
SELECT cu.id, '2026-11-17', '09:00:00', '12:00:00', 'NOT SPECIFIED', 'DAY', 'SBA', 'SBA Day Timetable', 40, 2, 'TUESDAY 17TH NOVEMBER', 'Advanced German (DIP)' FROM course_units cu WHERE cu.code = 'SBA' AND cu.name = 'Advanced German' AND cu.school = 'SBA' AND cu.degree_program = 'DIP' AND cu.year_of_study = 1 AND cu.semester = 1
UNION ALL
SELECT cu.id, '2026-11-17', '09:00:00', '12:00:00', 'NOT SPECIFIED', 'DAY', 'SBA', 'SBA Day Timetable', 41, 2, 'TUESDAY 17TH NOVEMBER', 'Laundry Operations (DEG)' FROM course_units cu WHERE cu.code = 'SBA' AND cu.name = 'Laundry Operations' AND cu.school = 'SBA' AND cu.degree_program = 'DEG' AND cu.year_of_study = 1 AND cu.semester = 1
UNION ALL
SELECT cu.id, '2026-11-17', '14:00:00', '17:00:00', 'NOT SPECIFIED', 'DAY', 'SBA', 'SBA Day Timetable', 42, 4, 'TUESDAY 17TH NOVEMBER', 'Financial Management/Business Finance 1 (DEG)' FROM course_units cu WHERE cu.code = 'SBA' AND cu.name = 'Financial Management/Business Finance 1' AND cu.school = 'SBA' AND cu.degree_program = 'DEG' AND cu.year_of_study = 1 AND cu.semester = 1
UNION ALL
SELECT cu.id, '2026-11-17', '14:00:00', '17:00:00', 'NOT SPECIFIED', 'DAY', 'SBA', 'SBA Day Timetable', 43, 4, 'TUESDAY 17TH NOVEMBER', 'Financial Management/Business Finance 1 (DIP)' FROM course_units cu WHERE cu.code = 'SBA' AND cu.name = 'Financial Management/Business Finance 1' AND cu.school = 'SBA' AND cu.degree_program = 'DIP' AND cu.year_of_study = 1 AND cu.semester = 1
UNION ALL
SELECT cu.id, '2026-11-17', '14:00:00', '17:00:00', 'NOT SPECIFIED', 'DAY', 'SBA', 'SBA Day Timetable', 44, 4, 'TUESDAY 17TH NOVEMBER', 'Management of Information Systems (DEG)' FROM course_units cu WHERE cu.code = 'SBA' AND cu.name = 'Management of Information Systems' AND cu.school = 'SBA' AND cu.degree_program = 'DEG' AND cu.year_of_study = 1 AND cu.semester = 1
UNION ALL
SELECT cu.id, '2026-11-17', '14:00:00', '17:00:00', 'NOT SPECIFIED', 'DAY', 'SBA', 'SBA Day Timetable', 45, 4, 'TUESDAY 17TH NOVEMBER', 'Management of Information Systems (DIP)' FROM course_units cu WHERE cu.code = 'SBA' AND cu.name = 'Management of Information Systems' AND cu.school = 'SBA' AND cu.degree_program = 'DIP' AND cu.year_of_study = 1 AND cu.semester = 1
UNION ALL
SELECT cu.id, '2026-11-17', '14:00:00', '17:00:00', 'NOT SPECIFIED', 'DAY', 'SBA', 'SBA Day Timetable', 46, 4, 'TUESDAY 17TH NOVEMBER', 'International Financial Markets & Banking (DEG)' FROM course_units cu WHERE cu.code = 'SBA' AND cu.name = 'International Financial Markets & Banking' AND cu.school = 'SBA' AND cu.degree_program = 'DEG' AND cu.year_of_study = 1 AND cu.semester = 1
UNION ALL
SELECT cu.id, '2026-11-17', '14:00:00', '17:00:00', 'NOT SPECIFIED', 'DAY', 'SBA', 'SBA Day Timetable', 47, 4, 'TUESDAY 17TH NOVEMBER', 'Procurement Contracts Management (DEG)' FROM course_units cu WHERE cu.code = 'SBA' AND cu.name = 'Procurement Contracts Management' AND cu.school = 'SBA' AND cu.degree_program = 'DEG' AND cu.year_of_study = 1 AND cu.semester = 1
UNION ALL
SELECT cu.id, '2026-11-17', '14:00:00', '17:00:00', 'NOT SPECIFIED', 'DAY', 'SBA', 'SBA Day Timetable', 48, 4, 'TUESDAY 17TH NOVEMBER', 'Medical Records Management (DEG)' FROM course_units cu WHERE cu.code = 'SBA' AND cu.name = 'Medical Records Management' AND cu.school = 'SBA' AND cu.degree_program = 'DEG' AND cu.year_of_study = 1 AND cu.semester = 1
UNION ALL
SELECT cu.id, '2026-11-17', '14:00:00', '17:00:00', 'NOT SPECIFIED', 'DAY', 'SBA', 'SBA Day Timetable', 49, 4, 'TUESDAY 17TH NOVEMBER', 'Library Cataloguing: theory and Practice (DIP)' FROM course_units cu WHERE cu.code = 'SBA' AND cu.name = 'Library Cataloguing: theory and Practice' AND cu.school = 'SBA' AND cu.degree_program = 'DIP' AND cu.year_of_study = 1 AND cu.semester = 1
UNION ALL
SELECT cu.id, '2026-11-17', '14:00:00', '17:00:00', 'NOT SPECIFIED', 'DAY', 'SBA', 'SBA Day Timetable', 50, 4, 'TUESDAY 17TH NOVEMBER', 'Sustainable Procurement (DEG)' FROM course_units cu WHERE cu.code = 'SBA' AND cu.name = 'Sustainable Procurement' AND cu.school = 'SBA' AND cu.degree_program = 'DEG' AND cu.year_of_study = 1 AND cu.semester = 1
UNION ALL
SELECT cu.id, '2026-11-17', '14:00:00', '17:00:00', 'NOT SPECIFIED', 'DAY', 'SBA', 'SBA Day Timetable', 51, 4, 'TUESDAY 17TH NOVEMBER', 'Principles of Tourism Management (DEG)' FROM course_units cu WHERE cu.code = 'SBA' AND cu.name = 'Principles of Tourism Management' AND cu.school = 'SBA' AND cu.degree_program = 'DEG' AND cu.year_of_study = 1 AND cu.semester = 1
UNION ALL
SELECT cu.id, '2026-11-18', '09:00:00', '12:00:00', 'NOT SPECIFIED', 'DAY', 'SBA', 'SBA Day Timetable', 52, 2, 'WEDNESDAY 18TH NOVEMBER', 'Taxation Management (DEG)' FROM course_units cu WHERE cu.code = 'SBA' AND cu.name = 'Taxation Management' AND cu.school = 'SBA' AND cu.degree_program = 'DEG' AND cu.year_of_study = 1 AND cu.semester = 1
UNION ALL
SELECT cu.id, '2026-11-18', '09:00:00', '12:00:00', 'NOT SPECIFIED', 'DAY', 'SBA', 'SBA Day Timetable', 53, 2, 'WEDNESDAY 18TH NOVEMBER', 'Taxation Management (DIP)' FROM course_units cu WHERE cu.code = 'SBA' AND cu.name = 'Taxation Management' AND cu.school = 'SBA' AND cu.degree_program = 'DIP' AND cu.year_of_study = 1 AND cu.semester = 1
UNION ALL
SELECT cu.id, '2026-11-18', '09:00:00', '12:00:00', 'NOT SPECIFIED', 'DAY', 'SBA', 'SBA Day Timetable', 54, 2, 'WEDNESDAY 18TH NOVEMBER', 'Auditing II (DEG)' FROM course_units cu WHERE cu.code = 'SBA' AND cu.name = 'Auditing II' AND cu.school = 'SBA' AND cu.degree_program = 'DEG' AND cu.year_of_study = 1 AND cu.semester = 1
UNION ALL
SELECT cu.id, '2026-11-18', '09:00:00', '12:00:00', 'NOT SPECIFIED', 'DAY', 'SBA', 'SBA Day Timetable', 55, 2, 'WEDNESDAY 18TH NOVEMBER', 'International Trade Law (DEG)' FROM course_units cu WHERE cu.code = 'SBA' AND cu.name = 'International Trade Law' AND cu.school = 'SBA' AND cu.degree_program = 'DEG' AND cu.year_of_study = 1 AND cu.semester = 1
UNION ALL
SELECT cu.id, '2026-11-18', '09:00:00', '12:00:00', 'NOT SPECIFIED', 'DAY', 'SBA', 'SBA Day Timetable', 56, 2, 'WEDNESDAY 18TH NOVEMBER', 'Procurement and Stores Management (DIP)' FROM course_units cu WHERE cu.code = 'SBA' AND cu.name = 'Procurement and Stores Management' AND cu.school = 'SBA' AND cu.degree_program = 'DIP' AND cu.year_of_study = 1 AND cu.semester = 1
UNION ALL
SELECT cu.id, '2026-11-18', '09:00:00', '12:00:00', 'NOT SPECIFIED', 'DAY', 'SBA', 'SBA Day Timetable', 57, 2, 'WEDNESDAY 18TH NOVEMBER', 'Foundation of Mathematics (HCBM)' FROM course_units cu WHERE cu.code = 'SBA' AND cu.name = 'Foundation of Mathematics' AND cu.school = 'SBA' AND cu.degree_program = 'HCBM' AND cu.year_of_study = 1 AND cu.semester = 1
UNION ALL
SELECT cu.id, '2026-11-18', '09:00:00', '12:00:00', 'NOT SPECIFIED', 'DAY', 'SBA', 'SBA Day Timetable', 58, 2, 'WEDNESDAY 18TH NOVEMBER', 'Housekeeping (DEG)' FROM course_units cu WHERE cu.code = 'SBA' AND cu.name = 'Housekeeping' AND cu.school = 'SBA' AND cu.degree_program = 'DEG' AND cu.year_of_study = 1 AND cu.semester = 1
UNION ALL
SELECT cu.id, '2026-11-18', '09:00:00', '12:00:00', 'NOT SPECIFIED', 'DAY', 'SBA', 'SBA Day Timetable', 59, 2, 'WEDNESDAY 18TH NOVEMBER', 'Housekeeping (DIP)' FROM course_units cu WHERE cu.code = 'SBA' AND cu.name = 'Housekeeping' AND cu.school = 'SBA' AND cu.degree_program = 'DIP' AND cu.year_of_study = 1 AND cu.semester = 1
UNION ALL
SELECT cu.id, '2026-11-18', '14:00:00', '17:00:00', 'NOT SPECIFIED', 'DAY', 'SBA', 'SBA Day Timetable', 60, 4, 'WEDNESDAY 18TH NOVEMBER', 'Human Resource Planning (DEG)' FROM course_units cu WHERE cu.code = 'SBA' AND cu.name = 'Human Resource Planning' AND cu.school = 'SBA' AND cu.degree_program = 'DEG' AND cu.year_of_study = 1 AND cu.semester = 1
UNION ALL
SELECT cu.id, '2026-11-18', '14:00:00', '17:00:00', 'NOT SPECIFIED', 'DAY', 'SBA', 'SBA Day Timetable', 61, 4, 'WEDNESDAY 18TH NOVEMBER', 'Reward Strategy and Management (DEG)' FROM course_units cu WHERE cu.code = 'SBA' AND cu.name = 'Reward Strategy and Management' AND cu.school = 'SBA' AND cu.degree_program = 'DEG' AND cu.year_of_study = 1 AND cu.semester = 1
UNION ALL
SELECT cu.id, '2026-11-18', '14:00:00', '17:00:00', 'NOT SPECIFIED', 'DAY', 'SBA', 'SBA Day Timetable', 62, 4, 'WEDNESDAY 18TH NOVEMBER', 'Museum Management (DEG)' FROM course_units cu WHERE cu.code = 'SBA' AND cu.name = 'Museum Management' AND cu.school = 'SBA' AND cu.degree_program = 'DEG' AND cu.year_of_study = 1 AND cu.semester = 1
UNION ALL
SELECT cu.id, '2026-11-18', '14:00:00', '17:00:00', 'NOT SPECIFIED', 'DAY', 'SBA', 'SBA Day Timetable', 63, 4, 'WEDNESDAY 18TH NOVEMBER', 'Sales and Sales Force Management (DIP)' FROM course_units cu WHERE cu.code = 'SBA' AND cu.name = 'Sales and Sales Force Management' AND cu.school = 'SBA' AND cu.degree_program = 'DIP' AND cu.year_of_study = 1 AND cu.semester = 1
UNION ALL
SELECT cu.id, '2026-11-18', '14:00:00', '17:00:00', 'NOT SPECIFIED', 'DAY', 'SBA', 'SBA Day Timetable', 64, 4, 'WEDNESDAY 18TH NOVEMBER', 'Introduction to Marketing (HCBM)' FROM course_units cu WHERE cu.code = 'SBA' AND cu.name = 'Introduction to Marketing' AND cu.school = 'SBA' AND cu.degree_program = 'HCBM' AND cu.year_of_study = 1 AND cu.semester = 1
UNION ALL
SELECT cu.id, '2026-11-19', '09:00:00', '12:00:00', 'NOT SPECIFIED', 'DAY', 'SBA', 'SBA Day Timetable', 65, 2, 'THURSDAY 19TH NOVEMBER', 'Entrepreneurship (DEG)' FROM course_units cu WHERE cu.code = 'SBA' AND cu.name = 'Entrepreneurship' AND cu.school = 'SBA' AND cu.degree_program = 'DEG' AND cu.year_of_study = 1 AND cu.semester = 1
UNION ALL
SELECT cu.id, '2026-11-19', '09:00:00', '12:00:00', 'NOT SPECIFIED', 'DAY', 'SBA', 'SBA Day Timetable', 66, 2, 'THURSDAY 19TH NOVEMBER', 'Entrepreneurship (DIP)' FROM course_units cu WHERE cu.code = 'SBA' AND cu.name = 'Entrepreneurship' AND cu.school = 'SBA' AND cu.degree_program = 'DIP' AND cu.year_of_study = 1 AND cu.semester = 1
UNION ALL
SELECT cu.id, '2026-11-19', '09:00:00', '12:00:00', 'NOT SPECIFIED', 'DAY', 'SBA', 'SBA Day Timetable', 67, 2, 'THURSDAY 19TH NOVEMBER', 'Principles of Procurement and Logistics Mgt (DEG)' FROM course_units cu WHERE cu.code = 'SBA' AND cu.name = 'Principles of Procurement and Logistics Mgt' AND cu.school = 'SBA' AND cu.degree_program = 'DEG' AND cu.year_of_study = 1 AND cu.semester = 1
UNION ALL
SELECT cu.id, '2026-11-19', '09:00:00', '12:00:00', 'NOT SPECIFIED', 'DAY', 'SBA', 'SBA Day Timetable', 68, 2, 'THURSDAY 19TH NOVEMBER', 'Economics I (DEG)' FROM course_units cu WHERE cu.code = 'SBA' AND cu.name = 'Economics I' AND cu.school = 'SBA' AND cu.degree_program = 'DEG' AND cu.year_of_study = 1 AND cu.semester = 1
UNION ALL
SELECT cu.id, '2026-11-19', '09:00:00', '12:00:00', 'NOT SPECIFIED', 'DAY', 'SBA', 'SBA Day Timetable', 69, 2, 'THURSDAY 19TH NOVEMBER', 'Economics I (DIP)' FROM course_units cu WHERE cu.code = 'SBA' AND cu.name = 'Economics I' AND cu.school = 'SBA' AND cu.degree_program = 'DIP' AND cu.year_of_study = 1 AND cu.semester = 1
UNION ALL
SELECT cu.id, '2026-11-19', '09:00:00', '12:00:00', 'NOT SPECIFIED', 'DAY', 'SBA', 'SBA Day Timetable', 70, 2, 'THURSDAY 19TH NOVEMBER', 'Import and Export Management (DEG)' FROM course_units cu WHERE cu.code = 'SBA' AND cu.name = 'Import and Export Management' AND cu.school = 'SBA' AND cu.degree_program = 'DEG' AND cu.year_of_study = 1 AND cu.semester = 1
UNION ALL
SELECT cu.id, '2026-11-19', '09:00:00', '12:00:00', 'NOT SPECIFIED', 'DAY', 'SBA', 'SBA Day Timetable', 71, 2, 'THURSDAY 19TH NOVEMBER', 'Retail Marketing (DEG)' FROM course_units cu WHERE cu.code = 'SBA' AND cu.name = 'Retail Marketing' AND cu.school = 'SBA' AND cu.degree_program = 'DEG' AND cu.year_of_study = 1 AND cu.semester = 1
UNION ALL
SELECT cu.id, '2026-11-19', '09:00:00', '12:00:00', 'NOT SPECIFIED', 'DAY', 'SBA', 'SBA Day Timetable', 72, 2, 'THURSDAY 19TH NOVEMBER', 'Customer Care (DEG)' FROM course_units cu WHERE cu.code = 'SBA' AND cu.name = 'Customer Care' AND cu.school = 'SBA' AND cu.degree_program = 'DEG' AND cu.year_of_study = 1 AND cu.semester = 1
UNION ALL
SELECT cu.id, '2026-11-19', '09:00:00', '12:00:00', 'NOT SPECIFIED', 'DAY', 'SBA', 'SBA Day Timetable', 73, 2, 'THURSDAY 19TH NOVEMBER', 'Customer Care (DIP)' FROM course_units cu WHERE cu.code = 'SBA' AND cu.name = 'Customer Care' AND cu.school = 'SBA' AND cu.degree_program = 'DIP' AND cu.year_of_study = 1 AND cu.semester = 1
UNION ALL
SELECT cu.id, '2026-11-19', '14:00:00', '17:00:00', 'NOT SPECIFIED', 'DAY', 'SBA', 'SBA Day Timetable', 74, 4, 'THURSDAY 19TH NOVEMBER', 'Intermediate Accounting (DEG)' FROM course_units cu WHERE cu.code = 'SBA' AND cu.name = 'Intermediate Accounting' AND cu.school = 'SBA' AND cu.degree_program = 'DEG' AND cu.year_of_study = 1 AND cu.semester = 1
UNION ALL
SELECT cu.id, '2026-11-19', '14:00:00', '17:00:00', 'NOT SPECIFIED', 'DAY', 'SBA', 'SBA Day Timetable', 75, 4, 'THURSDAY 19TH NOVEMBER', 'Intermediate Accounting (DIP)' FROM course_units cu WHERE cu.code = 'SBA' AND cu.name = 'Intermediate Accounting' AND cu.school = 'SBA' AND cu.degree_program = 'DIP' AND cu.year_of_study = 1 AND cu.semester = 1
UNION ALL
SELECT cu.id, '2026-11-19', '14:00:00', '17:00:00', 'NOT SPECIFIED', 'DAY', 'SBA', 'SBA Day Timetable', 76, 4, 'THURSDAY 19TH NOVEMBER', 'Public Sector Procurement (DEG)' FROM course_units cu WHERE cu.code = 'SBA' AND cu.name = 'Public Sector Procurement' AND cu.school = 'SBA' AND cu.degree_program = 'DEG' AND cu.year_of_study = 1 AND cu.semester = 1
UNION ALL
SELECT cu.id, '2026-11-19', '14:00:00', '17:00:00', 'NOT SPECIFIED', 'DAY', 'SBA', 'SBA Day Timetable', 77, 4, 'THURSDAY 19TH NOVEMBER', 'Economics Il (DEG)' FROM course_units cu WHERE cu.code = 'SBA' AND cu.name = 'Economics Il' AND cu.school = 'SBA' AND cu.degree_program = 'DEG' AND cu.year_of_study = 1 AND cu.semester = 1
UNION ALL
SELECT cu.id, '2026-11-19', '14:00:00', '17:00:00', 'NOT SPECIFIED', 'DAY', 'SBA', 'SBA Day Timetable', 78, 4, 'THURSDAY 19TH NOVEMBER', 'Economics Il (DIP)' FROM course_units cu WHERE cu.code = 'SBA' AND cu.name = 'Economics Il' AND cu.school = 'SBA' AND cu.degree_program = 'DIP' AND cu.year_of_study = 1 AND cu.semester = 1
UNION ALL
SELECT cu.id, '2026-11-19', '14:00:00', '17:00:00', 'NOT SPECIFIED', 'DAY', 'SBA', 'SBA Day Timetable', 79, 4, 'THURSDAY 19TH NOVEMBER', 'Dangerous Cargo Management (DEG)' FROM course_units cu WHERE cu.code = 'SBA' AND cu.name = 'Dangerous Cargo Management' AND cu.school = 'SBA' AND cu.degree_program = 'DEG' AND cu.year_of_study = 1 AND cu.semester = 1
UNION ALL
SELECT cu.id, '2026-11-19', '14:00:00', '17:00:00', 'NOT SPECIFIED', 'DAY', 'SBA', 'SBA Day Timetable', 80, 4, 'THURSDAY 19TH NOVEMBER', 'Records Preservation and Conservation (DEG)' FROM course_units cu WHERE cu.code = 'SBA' AND cu.name = 'Records Preservation and Conservation' AND cu.school = 'SBA' AND cu.degree_program = 'DEG' AND cu.year_of_study = 1 AND cu.semester = 1
UNION ALL
SELECT cu.id, '2026-11-19', '14:00:00', '17:00:00', 'NOT SPECIFIED', 'DAY', 'SBA', 'SBA Day Timetable', 81, 4, 'THURSDAY 19TH NOVEMBER', 'Records Preservation and Conservation (DIP)' FROM course_units cu WHERE cu.code = 'SBA' AND cu.name = 'Records Preservation and Conservation' AND cu.school = 'SBA' AND cu.degree_program = 'DIP' AND cu.year_of_study = 1 AND cu.semester = 1
UNION ALL
SELECT cu.id, '2026-11-19', '14:00:00', '17:00:00', 'NOT SPECIFIED', 'DAY', 'SBA', 'SBA Day Timetable', 82, 4, 'THURSDAY 19TH NOVEMBER', 'E-Procurement (DEG)' FROM course_units cu WHERE cu.code = 'SBA' AND cu.name = 'E-Procurement' AND cu.school = 'SBA' AND cu.degree_program = 'DEG' AND cu.year_of_study = 1 AND cu.semester = 1
UNION ALL
SELECT cu.id, '2026-11-20', '09:00:00', '12:00:00', 'NOT SPECIFIED', 'DAY', 'SBA', 'SBA Day Timetable', 83, 2, 'FRIDAY 20TH NOVEMBER', 'Labour Economics (DEG)' FROM course_units cu WHERE cu.code = 'SBA' AND cu.name = 'Labour Economics' AND cu.school = 'SBA' AND cu.degree_program = 'DEG' AND cu.year_of_study = 1 AND cu.semester = 1
UNION ALL
SELECT cu.id, '2026-11-20', '09:00:00', '12:00:00', 'NOT SPECIFIED', 'DAY', 'SBA', 'SBA Day Timetable', 84, 2, 'FRIDAY 20TH NOVEMBER', 'Labour Economics (DIP)' FROM course_units cu WHERE cu.code = 'SBA' AND cu.name = 'Labour Economics' AND cu.school = 'SBA' AND cu.degree_program = 'DIP' AND cu.year_of_study = 1 AND cu.semester = 1
UNION ALL
SELECT cu.id, '2026-11-20', '09:00:00', '12:00:00', 'NOT SPECIFIED', 'DAY', 'SBA', 'SBA Day Timetable', 85, 2, 'FRIDAY 20TH NOVEMBER', 'International Human Resource Mgt (DEG)' FROM course_units cu WHERE cu.code = 'SBA' AND cu.name = 'International Human Resource Mgt' AND cu.school = 'SBA' AND cu.degree_program = 'DEG' AND cu.year_of_study = 1 AND cu.semester = 1
UNION ALL
SELECT cu.id, '2026-11-20', '09:00:00', '12:00:00', 'NOT SPECIFIED', 'DAY', 'SBA', 'SBA Day Timetable', 86, 2, 'FRIDAY 20TH NOVEMBER', 'Customs Declaration and Tariffs (DEG)' FROM course_units cu WHERE cu.code = 'SBA' AND cu.name = 'Customs Declaration and Tariffs' AND cu.school = 'SBA' AND cu.degree_program = 'DEG' AND cu.year_of_study = 1 AND cu.semester = 1
UNION ALL
SELECT cu.id, '2026-11-20', '09:00:00', '12:00:00', 'NOT SPECIFIED', 'DAY', 'SBA', 'SBA Day Timetable', 87, 2, 'FRIDAY 20TH NOVEMBER', 'Business Policy (DIP)' FROM course_units cu WHERE cu.code = 'SBA' AND cu.name = 'Business Policy' AND cu.school = 'SBA' AND cu.degree_program = 'DIP' AND cu.year_of_study = 1 AND cu.semester = 1
UNION ALL
SELECT cu.id, '2026-11-20', '09:00:00', '12:00:00', 'NOT SPECIFIED', 'DAY', 'SBA', 'SBA Day Timetable', 88, 2, 'FRIDAY 20TH NOVEMBER', 'Communication Skills (HCBM)' FROM course_units cu WHERE cu.code = 'SBA' AND cu.name = 'Communication Skills' AND cu.school = 'SBA' AND cu.degree_program = 'HCBM' AND cu.year_of_study = 1 AND cu.semester = 1
UNION ALL
SELECT cu.id, '2026-11-20', '09:00:00', '12:00:00', 'NOT SPECIFIED', 'DAY', 'SBA', 'SBA Day Timetable', 89, 2, 'FRIDAY 20TH NOVEMBER', 'Health and Hygiene/Food hygiene and Safety (DEG)' FROM course_units cu WHERE cu.code = 'SBA' AND cu.name = 'Health and Hygiene/Food hygiene and Safety' AND cu.school = 'SBA' AND cu.degree_program = 'DEG' AND cu.year_of_study = 1 AND cu.semester = 1
UNION ALL
SELECT cu.id, '2026-11-20', '09:00:00', '12:00:00', 'NOT SPECIFIED', 'DAY', 'SBA', 'SBA Day Timetable', 90, 2, 'FRIDAY 20TH NOVEMBER', 'Health and Hygiene/Food hygiene and Safety (DIP)' FROM course_units cu WHERE cu.code = 'SBA' AND cu.name = 'Health and Hygiene/Food hygiene and Safety' AND cu.school = 'SBA' AND cu.degree_program = 'DIP' AND cu.year_of_study = 1 AND cu.semester = 1
UNION ALL
SELECT cu.id, '2026-11-20', '09:00:00', '12:00:00', 'NOT SPECIFIED', 'DAY', 'SBA', 'SBA Day Timetable', 91, 2, 'FRIDAY 20TH NOVEMBER', 'Tourism Product Development (DEG)' FROM course_units cu WHERE cu.code = 'SBA' AND cu.name = 'Tourism Product Development' AND cu.school = 'SBA' AND cu.degree_program = 'DEG' AND cu.year_of_study = 1 AND cu.semester = 1
UNION ALL
SELECT cu.id, '2026-11-20', '14:00:00', '17:00:00', 'NOT SPECIFIED', 'DAY', 'SBA', 'SBA Day Timetable', 92, 4, 'FRIDAY 20TH NOVEMBER', 'Operations Research (DEG)' FROM course_units cu WHERE cu.code = 'SBA' AND cu.name = 'Operations Research' AND cu.school = 'SBA' AND cu.degree_program = 'DEG' AND cu.year_of_study = 1 AND cu.semester = 1
UNION ALL
SELECT cu.id, '2026-11-20', '14:00:00', '17:00:00', 'NOT SPECIFIED', 'DAY', 'SBA', 'SBA Day Timetable', 93, 4, 'FRIDAY 20TH NOVEMBER', 'Employee Relations (DEG)' FROM course_units cu WHERE cu.code = 'SBA' AND cu.name = 'Employee Relations' AND cu.school = 'SBA' AND cu.degree_program = 'DEG' AND cu.year_of_study = 1 AND cu.semester = 1
UNION ALL
SELECT cu.id, '2026-11-20', '14:00:00', '17:00:00', 'NOT SPECIFIED', 'DAY', 'SBA', 'SBA Day Timetable', 94, 4, 'FRIDAY 20TH NOVEMBER', 'Small Business Management (DIP)' FROM course_units cu WHERE cu.code = 'SBA' AND cu.name = 'Small Business Management' AND cu.school = 'SBA' AND cu.degree_program = 'DIP' AND cu.year_of_study = 1 AND cu.semester = 1
UNION ALL
SELECT cu.id, '2026-11-20', '14:00:00', '17:00:00', 'NOT SPECIFIED', 'DAY', 'SBA', 'SBA Day Timetable', 95, 4, 'FRIDAY 20TH NOVEMBER', 'User Services and user Relations (DIP)' FROM course_units cu WHERE cu.code = 'SBA' AND cu.name = 'User Services and user Relations' AND cu.school = 'SBA' AND cu.degree_program = 'DIP' AND cu.year_of_study = 1 AND cu.semester = 1
UNION ALL
SELECT cu.id, '2026-11-20', '14:00:00', '17:00:00', 'NOT SPECIFIED', 'DAY', 'SBA', 'SBA Day Timetable', 96, 4, 'FRIDAY 20TH NOVEMBER', 'Entrepreneurship and Small Business (HCBM)' FROM course_units cu WHERE cu.code = 'SBA' AND cu.name = 'Entrepreneurship and Small Business' AND cu.school = 'SBA' AND cu.degree_program = 'HCBM' AND cu.year_of_study = 1 AND cu.semester = 1
UNION ALL
SELECT cu.id, '2026-11-20', '14:00:00', '17:00:00', 'NOT SPECIFIED', 'DAY', 'SBA', 'SBA Day Timetable', 97, 4, 'FRIDAY 20TH NOVEMBER', 'Purchasing & Supplies Management (DIP)' FROM course_units cu WHERE cu.code = 'SBA' AND cu.name = 'Purchasing & Supplies Management' AND cu.school = 'SBA' AND cu.degree_program = 'DIP' AND cu.year_of_study = 1 AND cu.semester = 1
UNION ALL
SELECT cu.id, '2026-11-23', '09:00:00', '12:00:00', 'NOT SPECIFIED', 'DAY', 'SBA', 'SBA Day Timetable', 98, 2, 'MONDAY 23RD NOVEMBER', 'Business Ethics (DEG)' FROM course_units cu WHERE cu.code = 'SBA' AND cu.name = 'Business Ethics' AND cu.school = 'SBA' AND cu.degree_program = 'DEG' AND cu.year_of_study = 1 AND cu.semester = 1
UNION ALL
SELECT cu.id, '2026-11-23', '09:00:00', '12:00:00', 'NOT SPECIFIED', 'DAY', 'SBA', 'SBA Day Timetable', 99, 2, 'MONDAY 23RD NOVEMBER', 'Business Ethics (DIP)' FROM course_units cu WHERE cu.code = 'SBA' AND cu.name = 'Business Ethics' AND cu.school = 'SBA' AND cu.degree_program = 'DIP' AND cu.year_of_study = 1 AND cu.semester = 1
UNION ALL
SELECT cu.id, '2026-11-23', '09:00:00', '12:00:00', 'NOT SPECIFIED', 'DAY', 'SBA', 'SBA Day Timetable', 100, 2, 'MONDAY 23RD NOVEMBER', 'Customer Service Management (DEG)' FROM course_units cu WHERE cu.code = 'SBA' AND cu.name = 'Customer Service Management' AND cu.school = 'SBA' AND cu.degree_program = 'DEG' AND cu.year_of_study = 1 AND cu.semester = 1
UNION ALL
SELECT cu.id, '2026-11-23', '09:00:00', '12:00:00', 'NOT SPECIFIED', 'DAY', 'SBA', 'SBA Day Timetable', 101, 2, 'MONDAY 23RD NOVEMBER', 'Procurement Negotiation Management (DEG)' FROM course_units cu WHERE cu.code = 'SBA' AND cu.name = 'Procurement Negotiation Management' AND cu.school = 'SBA' AND cu.degree_program = 'DEG' AND cu.year_of_study = 1 AND cu.semester = 1
UNION ALL
SELECT cu.id, '2026-11-23', '09:00:00', '12:00:00', 'NOT SPECIFIED', 'DAY', 'SBA', 'SBA Day Timetable', 102, 2, 'MONDAY 23RD NOVEMBER', 'Workplace Counselling/Employee Counselling (DEG)' FROM course_units cu WHERE cu.code = 'SBA' AND cu.name = 'Workplace Counselling/Employee Counselling' AND cu.school = 'SBA' AND cu.degree_program = 'DEG' AND cu.year_of_study = 1 AND cu.semester = 1
UNION ALL
SELECT cu.id, '2026-11-23', '09:00:00', '12:00:00', 'NOT SPECIFIED', 'DAY', 'SBA', 'SBA Day Timetable', 103, 2, 'MONDAY 23RD NOVEMBER', 'Fundamentals of Procurement Management (DEG)' FROM course_units cu WHERE cu.code = 'SBA' AND cu.name = 'Fundamentals of Procurement Management' AND cu.school = 'SBA' AND cu.degree_program = 'DEG' AND cu.year_of_study = 1 AND cu.semester = 1
UNION ALL
SELECT cu.id, '2026-11-23', '09:00:00', '12:00:00', 'NOT SPECIFIED', 'DAY', 'SBA', 'SBA Day Timetable', 104, 2, 'MONDAY 23RD NOVEMBER', 'Insurance Management (DEG)' FROM course_units cu WHERE cu.code = 'SBA' AND cu.name = 'Insurance Management' AND cu.school = 'SBA' AND cu.degree_program = 'DEG' AND cu.year_of_study = 1 AND cu.semester = 1
UNION ALL
SELECT cu.id, '2026-11-23', '09:00:00', '12:00:00', 'NOT SPECIFIED', 'DAY', 'SBA', 'SBA Day Timetable', 105, 2, 'MONDAY 23RD NOVEMBER', 'Office Records Management (DIP)' FROM course_units cu WHERE cu.code = 'SBA' AND cu.name = 'Office Records Management' AND cu.school = 'SBA' AND cu.degree_program = 'DIP' AND cu.year_of_study = 1 AND cu.semester = 1
UNION ALL
SELECT cu.id, '2026-11-23', '14:00:00', '17:00:00', 'NOT SPECIFIED', 'DAY', 'SBA', 'SBA Day Timetable', 106, 4, 'MONDAY 23RD NOVEMBER', 'Systems Analysis & Design (DEG)' FROM course_units cu WHERE cu.code = 'SBA' AND cu.name = 'Systems Analysis & Design' AND cu.school = 'SBA' AND cu.degree_program = 'DEG' AND cu.year_of_study = 1 AND cu.semester = 1
UNION ALL
SELECT cu.id, '2026-11-23', '14:00:00', '17:00:00', 'NOT SPECIFIED', 'DAY', 'SBA', 'SBA Day Timetable', 107, 4, 'MONDAY 23RD NOVEMBER', 'Banking & Insurance Laws (DEG)' FROM course_units cu WHERE cu.code = 'SBA' AND cu.name = 'Banking & Insurance Laws' AND cu.school = 'SBA' AND cu.degree_program = 'DEG' AND cu.year_of_study = 1 AND cu.semester = 1
UNION ALL
SELECT cu.id, '2026-11-23', '14:00:00', '17:00:00', 'NOT SPECIFIED', 'DAY', 'SBA', 'SBA Day Timetable', 108, 4, 'MONDAY 23RD NOVEMBER', 'Human Resource Management in the Supply Chain (DEG)' FROM course_units cu WHERE cu.code = 'SBA' AND cu.name = 'Human Resource Management in the Supply Chain' AND cu.school = 'SBA' AND cu.degree_program = 'DEG' AND cu.year_of_study = 1 AND cu.semester = 1
UNION ALL
SELECT cu.id, '2026-11-23', '14:00:00', '17:00:00', 'NOT SPECIFIED', 'DAY', 'SBA', 'SBA Day Timetable', 109, 4, 'MONDAY 23RD NOVEMBER', 'Ethics in Human Resource Mgt (DEG)' FROM course_units cu WHERE cu.code = 'SBA' AND cu.name = 'Ethics in Human Resource Mgt' AND cu.school = 'SBA' AND cu.degree_program = 'DEG' AND cu.year_of_study = 1 AND cu.semester = 1
UNION ALL
SELECT cu.id, '2026-11-23', '14:00:00', '17:00:00', 'NOT SPECIFIED', 'DAY', 'SBA', 'SBA Day Timetable', 110, 4, 'MONDAY 23RD NOVEMBER', 'Economics of Sea Transport Management (DEG)' FROM course_units cu WHERE cu.code = 'SBA' AND cu.name = 'Economics of Sea Transport Management' AND cu.school = 'SBA' AND cu.degree_program = 'DEG' AND cu.year_of_study = 1 AND cu.semester = 1
UNION ALL
SELECT cu.id, '2026-11-23', '14:00:00', '17:00:00', 'NOT SPECIFIED', 'DAY', 'SBA', 'SBA Day Timetable', 111, 4, 'MONDAY 23RD NOVEMBER', 'Archives Administration and Management (DEG)' FROM course_units cu WHERE cu.code = 'SBA' AND cu.name = 'Archives Administration and Management' AND cu.school = 'SBA' AND cu.degree_program = 'DEG' AND cu.year_of_study = 1 AND cu.semester = 1
UNION ALL
SELECT cu.id, '2026-11-23', '14:00:00', '17:00:00', 'NOT SPECIFIED', 'DAY', 'SBA', 'SBA Day Timetable', 112, 4, 'MONDAY 23RD NOVEMBER', 'Archives Administration and Management (DIP)' FROM course_units cu WHERE cu.code = 'SBA' AND cu.name = 'Archives Administration and Management' AND cu.school = 'SBA' AND cu.degree_program = 'DIP' AND cu.year_of_study = 1 AND cu.semester = 1
UNION ALL
SELECT cu.id, '2026-11-23', '14:00:00', '17:00:00', 'NOT SPECIFIED', 'DAY', 'SBA', 'SBA Day Timetable', 113, 4, 'MONDAY 23RD NOVEMBER', 'Procurement Ethics Audit & Investigation (DEG)' FROM course_units cu WHERE cu.code = 'SBA' AND cu.name = 'Procurement Ethics Audit & Investigation' AND cu.school = 'SBA' AND cu.degree_program = 'DEG' AND cu.year_of_study = 1 AND cu.semester = 1
UNION ALL
SELECT cu.id, '2026-11-24', '09:00:00', '12:00:00', 'NOT SPECIFIED', 'DAY', 'SBA', 'SBA Day Timetable', 114, 2, 'TUESDAY 24TH NOVEMBER', 'Management Accounting (DEG)' FROM course_units cu WHERE cu.code = 'SBA' AND cu.name = 'Management Accounting' AND cu.school = 'SBA' AND cu.degree_program = 'DEG' AND cu.year_of_study = 1 AND cu.semester = 1
UNION ALL
SELECT cu.id, '2026-11-24', '09:00:00', '12:00:00', 'NOT SPECIFIED', 'DAY', 'SBA', 'SBA Day Timetable', 115, 2, 'TUESDAY 24TH NOVEMBER', 'Logistics and Procurement Communication (DEG)' FROM course_units cu WHERE cu.code = 'SBA' AND cu.name = 'Logistics and Procurement Communication' AND cu.school = 'SBA' AND cu.degree_program = 'DEG' AND cu.year_of_study = 1 AND cu.semester = 1
UNION ALL
SELECT cu.id, '2026-11-24', '09:00:00', '12:00:00', 'NOT SPECIFIED', 'DAY', 'SBA', 'SBA Day Timetable', 116, 2, 'TUESDAY 24TH NOVEMBER', 'Human Resource Training (DEG)' FROM course_units cu WHERE cu.code = 'SBA' AND cu.name = 'Human Resource Training' AND cu.school = 'SBA' AND cu.degree_program = 'DEG' AND cu.year_of_study = 1 AND cu.semester = 1
UNION ALL
SELECT cu.id, '2026-11-24', '09:00:00', '12:00:00', 'NOT SPECIFIED', 'DAY', 'SBA', 'SBA Day Timetable', 117, 2, 'TUESDAY 24TH NOVEMBER', 'Community Information Services (DEG)' FROM course_units cu WHERE cu.code = 'SBA' AND cu.name = 'Community Information Services' AND cu.school = 'SBA' AND cu.degree_program = 'DEG' AND cu.year_of_study = 1 AND cu.semester = 1
UNION ALL
SELECT cu.id, '2026-11-24', '09:00:00', '12:00:00', 'NOT SPECIFIED', 'DAY', 'SBA', 'SBA Day Timetable', 118, 2, 'TUESDAY 24TH NOVEMBER', 'Introduction to Development Studies (HCBM)' FROM course_units cu WHERE cu.code = 'SBA' AND cu.name = 'Introduction to Development Studies' AND cu.school = 'SBA' AND cu.degree_program = 'HCBM' AND cu.year_of_study = 1 AND cu.semester = 1
UNION ALL
SELECT cu.id, '2026-11-24', '09:00:00', '12:00:00', 'NOT SPECIFIED', 'DAY', 'SBA', 'SBA Day Timetable', 119, 2, 'TUESDAY 24TH NOVEMBER', 'Organisation Staffing & Management (DEG)' FROM course_units cu WHERE cu.code = 'SBA' AND cu.name = 'Organisation Staffing & Management' AND cu.school = 'SBA' AND cu.degree_program = 'DEG' AND cu.year_of_study = 1 AND cu.semester = 1
UNION ALL
SELECT cu.id, '2026-11-24', '09:00:00', '12:00:00', 'NOT SPECIFIED', 'DAY', 'SBA', 'SBA Day Timetable', 120, 2, 'TUESDAY 24TH NOVEMBER', 'Food Service Operations (DEG)' FROM course_units cu WHERE cu.code = 'SBA' AND cu.name = 'Food Service Operations' AND cu.school = 'SBA' AND cu.degree_program = 'DEG' AND cu.year_of_study = 1 AND cu.semester = 1
UNION ALL
SELECT cu.id, '2026-11-24', '09:00:00', '12:00:00', 'NOT SPECIFIED', 'DAY', 'SBA', 'SBA Day Timetable', 121, 2, 'TUESDAY 24TH NOVEMBER', 'Food Service Operations (DIP)' FROM course_units cu WHERE cu.code = 'SBA' AND cu.name = 'Food Service Operations' AND cu.school = 'SBA' AND cu.degree_program = 'DIP' AND cu.year_of_study = 1 AND cu.semester = 1
UNION ALL
SELECT cu.id, '2026-11-24', '14:00:00', '17:00:00', 'NOT SPECIFIED', 'DAY', 'SBA', 'SBA Day Timetable', 122, 4, 'TUESDAY 24TH NOVEMBER', 'Human Resource Management (DEG)' FROM course_units cu WHERE cu.code = 'SBA' AND cu.name = 'Human Resource Management' AND cu.school = 'SBA' AND cu.degree_program = 'DEG' AND cu.year_of_study = 1 AND cu.semester = 1
UNION ALL
SELECT cu.id, '2026-11-24', '14:00:00', '17:00:00', 'NOT SPECIFIED', 'DAY', 'SBA', 'SBA Day Timetable', 123, 4, 'TUESDAY 24TH NOVEMBER', 'Procurement Law (DEG)' FROM course_units cu WHERE cu.code = 'SBA' AND cu.name = 'Procurement Law' AND cu.school = 'SBA' AND cu.degree_program = 'DEG' AND cu.year_of_study = 1 AND cu.semester = 1
UNION ALL
SELECT cu.id, '2026-11-24', '14:00:00', '17:00:00', 'NOT SPECIFIED', 'DAY', 'SBA', 'SBA Day Timetable', 124, 4, 'TUESDAY 24TH NOVEMBER', 'H.R Management Information Systems (DEG)' FROM course_units cu WHERE cu.code = 'SBA' AND cu.name = 'H.R Management Information Systems' AND cu.school = 'SBA' AND cu.degree_program = 'DEG' AND cu.year_of_study = 1 AND cu.semester = 1
UNION ALL
SELECT cu.id, '2026-11-24', '14:00:00', '17:00:00', 'NOT SPECIFIED', 'DAY', 'SBA', 'SBA Day Timetable', 125, 4, 'TUESDAY 24TH NOVEMBER', 'Logistics and Distribution Management (DEG)' FROM course_units cu WHERE cu.code = 'SBA' AND cu.name = 'Logistics and Distribution Management' AND cu.school = 'SBA' AND cu.degree_program = 'DEG' AND cu.year_of_study = 1 AND cu.semester = 1
UNION ALL
SELECT cu.id, '2026-11-24', '14:00:00', '17:00:00', 'NOT SPECIFIED', 'DAY', 'SBA', 'SBA Day Timetable', 126, 4, 'TUESDAY 24TH NOVEMBER', 'Compliance and Regulatory Environ in RIM (DIP)' FROM course_units cu WHERE cu.code = 'SBA' AND cu.name = 'Compliance and Regulatory Environ in RIM' AND cu.school = 'SBA' AND cu.degree_program = 'DIP' AND cu.year_of_study = 1 AND cu.semester = 1
UNION ALL
SELECT cu.id, '2026-11-24', '14:00:00', '17:00:00', 'NOT SPECIFIED', 'DAY', 'SBA', 'SBA Day Timetable', 127, 4, 'TUESDAY 24TH NOVEMBER', 'Introduction to Human Resource Management (HCBM)' FROM course_units cu WHERE cu.code = 'SBA' AND cu.name = 'Introduction to Human Resource Management' AND cu.school = 'SBA' AND cu.degree_program = 'HCBM' AND cu.year_of_study = 1 AND cu.semester = 1
UNION ALL
SELECT cu.id, '2026-11-24', '14:00:00', '17:00:00', 'NOT SPECIFIED', 'DAY', 'SBA', 'SBA Day Timetable', 128, 4, 'TUESDAY 24TH NOVEMBER', 'Fundamentals of Tourism (DEG)' FROM course_units cu WHERE cu.code = 'SBA' AND cu.name = 'Fundamentals of Tourism' AND cu.school = 'SBA' AND cu.degree_program = 'DEG' AND cu.year_of_study = 1 AND cu.semester = 1
UNION ALL
SELECT cu.id, '2026-11-24', '14:00:00', '17:00:00', 'NOT SPECIFIED', 'DAY', 'SBA', 'SBA Day Timetable', 129, 4, 'TUESDAY 24TH NOVEMBER', 'Fundamentals of Tourism (DIP)' FROM course_units cu WHERE cu.code = 'SBA' AND cu.name = 'Fundamentals of Tourism' AND cu.school = 'SBA' AND cu.degree_program = 'DIP' AND cu.year_of_study = 1 AND cu.semester = 1
UNION ALL
SELECT cu.id, '2026-11-25', '09:00:00', '12:00:00', 'NOT SPECIFIED', 'DAY', 'SBA', 'SBA Day Timetable', 130, 2, 'WEDNESDAY 25TH NOVEMBER', 'Cost Accounting (DEG)' FROM course_units cu WHERE cu.code = 'SBA' AND cu.name = 'Cost Accounting' AND cu.school = 'SBA' AND cu.degree_program = 'DEG' AND cu.year_of_study = 1 AND cu.semester = 1
UNION ALL
SELECT cu.id, '2026-11-25', '09:00:00', '12:00:00', 'NOT SPECIFIED', 'DAY', 'SBA', 'SBA Day Timetable', 131, 2, 'WEDNESDAY 25TH NOVEMBER', 'Cost Accounting (DIP)' FROM course_units cu WHERE cu.code = 'SBA' AND cu.name = 'Cost Accounting' AND cu.school = 'SBA' AND cu.degree_program = 'DIP' AND cu.year_of_study = 1 AND cu.semester = 1
UNION ALL
SELECT cu.id, '2026-11-25', '09:00:00', '12:00:00', 'NOT SPECIFIED', 'DAY', 'SBA', 'SBA Day Timetable', 132, 2, 'WEDNESDAY 25TH NOVEMBER', 'International Marketing (DEG)' FROM course_units cu WHERE cu.code = 'SBA' AND cu.name = 'International Marketing' AND cu.school = 'SBA' AND cu.degree_program = 'DEG' AND cu.year_of_study = 1 AND cu.semester = 1
UNION ALL
SELECT cu.id, '2026-11-25', '09:00:00', '12:00:00', 'NOT SPECIFIED', 'DAY', 'SBA', 'SBA Day Timetable', 133, 2, 'WEDNESDAY 25TH NOVEMBER', 'Warehousing and Inventory Management (DEG)' FROM course_units cu WHERE cu.code = 'SBA' AND cu.name = 'Warehousing and Inventory Management' AND cu.school = 'SBA' AND cu.degree_program = 'DEG' AND cu.year_of_study = 1 AND cu.semester = 1
UNION ALL
SELECT cu.id, '2026-11-25', '09:00:00', '12:00:00', 'NOT SPECIFIED', 'DAY', 'SBA', 'SBA Day Timetable', 134, 2, 'WEDNESDAY 25TH NOVEMBER', 'Shipping Principles and Practices (DEG)' FROM course_units cu WHERE cu.code = 'SBA' AND cu.name = 'Shipping Principles and Practices' AND cu.school = 'SBA' AND cu.degree_program = 'DEG' AND cu.year_of_study = 1 AND cu.semester = 1
UNION ALL
SELECT cu.id, '2026-11-25', '09:00:00', '12:00:00', 'NOT SPECIFIED', 'DAY', 'SBA', 'SBA Day Timetable', 135, 2, 'WEDNESDAY 25TH NOVEMBER', 'Information Sources, Systems and Services (DEG)' FROM course_units cu WHERE cu.code = 'SBA' AND cu.name = 'Information Sources, Systems and Services' AND cu.school = 'SBA' AND cu.degree_program = 'DEG' AND cu.year_of_study = 1 AND cu.semester = 1
UNION ALL
SELECT cu.id, '2026-11-25', '09:00:00', '12:00:00', 'NOT SPECIFIED', 'DAY', 'SBA', 'SBA Day Timetable', 136, 2, 'WEDNESDAY 25TH NOVEMBER', 'Food Service Equipment and Design (DEG)' FROM course_units cu WHERE cu.code = 'SBA' AND cu.name = 'Food Service Equipment and Design' AND cu.school = 'SBA' AND cu.degree_program = 'DEG' AND cu.year_of_study = 1 AND cu.semester = 1
UNION ALL
SELECT cu.id, '2026-11-25', '14:00:00', '17:00:00', 'NOT SPECIFIED', 'DAY', 'SBA', 'SBA Day Timetable', 137, 4, 'WEDNESDAY 25TH NOVEMBER', 'Money, Banking and Insurance (DEG)' FROM course_units cu WHERE cu.code = 'SBA' AND cu.name = 'Money, Banking and Insurance' AND cu.school = 'SBA' AND cu.degree_program = 'DEG' AND cu.year_of_study = 1 AND cu.semester = 1
UNION ALL
SELECT cu.id, '2026-11-25', '14:00:00', '17:00:00', 'NOT SPECIFIED', 'DAY', 'SBA', 'SBA Day Timetable', 138, 4, 'WEDNESDAY 25TH NOVEMBER', 'Money, Banking and Insurance (DIP)' FROM course_units cu WHERE cu.code = 'SBA' AND cu.name = 'Money, Banking and Insurance' AND cu.school = 'SBA' AND cu.degree_program = 'DIP' AND cu.year_of_study = 1 AND cu.semester = 1
UNION ALL
SELECT cu.id, '2026-11-25', '14:00:00', '17:00:00', 'NOT SPECIFIED', 'DAY', 'SBA', 'SBA Day Timetable', 139, 4, 'WEDNESDAY 25TH NOVEMBER', 'Life and General Insurance (DEG)' FROM course_units cu WHERE cu.code = 'SBA' AND cu.name = 'Life and General Insurance' AND cu.school = 'SBA' AND cu.degree_program = 'DEG' AND cu.year_of_study = 1 AND cu.semester = 1
UNION ALL
SELECT cu.id, '2026-11-25', '14:00:00', '17:00:00', 'NOT SPECIFIED', 'DAY', 'SBA', 'SBA Day Timetable', 140, 4, 'WEDNESDAY 25TH NOVEMBER', 'Strategic Procurement Management (DEG)' FROM course_units cu WHERE cu.code = 'SBA' AND cu.name = 'Strategic Procurement Management' AND cu.school = 'SBA' AND cu.degree_program = 'DEG' AND cu.year_of_study = 1 AND cu.semester = 1
UNION ALL
SELECT cu.id, '2026-11-25', '14:00:00', '17:00:00', 'NOT SPECIFIED', 'DAY', 'SBA', 'SBA Day Timetable', 141, 4, 'WEDNESDAY 25TH NOVEMBER', 'Clearing and Forwading Law (DEG)' FROM course_units cu WHERE cu.code = 'SBA' AND cu.name = 'Clearing and Forwading Law' AND cu.school = 'SBA' AND cu.degree_program = 'DEG' AND cu.year_of_study = 1 AND cu.semester = 1
UNION ALL
SELECT cu.id, '2026-11-25', '14:00:00', '17:00:00', 'NOT SPECIFIED', 'DAY', 'SBA', 'SBA Day Timetable', 142, 4, 'WEDNESDAY 25TH NOVEMBER', 'Management Information Systems (DEG)' FROM course_units cu WHERE cu.code = 'SBA' AND cu.name = 'Management Information Systems' AND cu.school = 'SBA' AND cu.degree_program = 'DEG' AND cu.year_of_study = 1 AND cu.semester = 1
UNION ALL
SELECT cu.id, '2026-11-25', '14:00:00', '17:00:00', 'NOT SPECIFIED', 'DAY', 'SBA', 'SBA Day Timetable', 143, 4, 'WEDNESDAY 25TH NOVEMBER', 'Management Information Systems (DIP)' FROM course_units cu WHERE cu.code = 'SBA' AND cu.name = 'Management Information Systems' AND cu.school = 'SBA' AND cu.degree_program = 'DIP' AND cu.year_of_study = 1 AND cu.semester = 1
UNION ALL
SELECT cu.id, '2026-11-25', '14:00:00', '17:00:00', 'NOT SPECIFIED', 'DAY', 'SBA', 'SBA Day Timetable', 144, 4, 'WEDNESDAY 25TH NOVEMBER', 'Managing Supplier Relations in Procurement (DEG)' FROM course_units cu WHERE cu.code = 'SBA' AND cu.name = 'Managing Supplier Relations in Procurement' AND cu.school = 'SBA' AND cu.degree_program = 'DEG' AND cu.year_of_study = 1 AND cu.semester = 1
UNION ALL
SELECT cu.id, '2026-11-26', '09:00:00', '12:00:00', 'NOT SPECIFIED', 'DAY', 'SBA', 'SBA Day Timetable', 145, 2, 'THURSDAY 26TH NOVEMBER', 'Fundamentals of Accounting (DEG)' FROM course_units cu WHERE cu.code = 'SBA' AND cu.name = 'Fundamentals of Accounting' AND cu.school = 'SBA' AND cu.degree_program = 'DEG' AND cu.year_of_study = 1 AND cu.semester = 1
UNION ALL
SELECT cu.id, '2026-11-26', '09:00:00', '12:00:00', 'NOT SPECIFIED', 'DAY', 'SBA', 'SBA Day Timetable', 146, 2, 'THURSDAY 26TH NOVEMBER', 'Fundamentals of Accounting (DIP)' FROM course_units cu WHERE cu.code = 'SBA' AND cu.name = 'Fundamentals of Accounting' AND cu.school = 'SBA' AND cu.degree_program = 'DIP' AND cu.year_of_study = 1 AND cu.semester = 1
UNION ALL
SELECT cu.id, '2026-11-26', '09:00:00', '12:00:00', 'NOT SPECIFIED', 'DAY', 'SBA', 'SBA Day Timetable', 147, 2, 'THURSDAY 26TH NOVEMBER', 'Comparative Business Management (DEG)' FROM course_units cu WHERE cu.code = 'SBA' AND cu.name = 'Comparative Business Management' AND cu.school = 'SBA' AND cu.degree_program = 'DEG' AND cu.year_of_study = 1 AND cu.semester = 1
UNION ALL
SELECT cu.id, '2026-11-26', '09:00:00', '12:00:00', 'NOT SPECIFIED', 'DAY', 'SBA', 'SBA Day Timetable', 148, 2, 'THURSDAY 26TH NOVEMBER', 'Investment Analysis (DEG)' FROM course_units cu WHERE cu.code = 'SBA' AND cu.name = 'Investment Analysis' AND cu.school = 'SBA' AND cu.degree_program = 'DEG' AND cu.year_of_study = 1 AND cu.semester = 1
UNION ALL
SELECT cu.id, '2026-11-26', '09:00:00', '12:00:00', 'NOT SPECIFIED', 'DAY', 'SBA', 'SBA Day Timetable', 149, 2, 'THURSDAY 26TH NOVEMBER', 'Information Institutions and Resources (DIP)' FROM course_units cu WHERE cu.code = 'SBA' AND cu.name = 'Information Institutions and Resources' AND cu.school = 'SBA' AND cu.degree_program = 'DIP' AND cu.year_of_study = 1 AND cu.semester = 1
UNION ALL
SELECT cu.id, '2026-11-26', '09:00:00', '12:00:00', 'NOT SPECIFIED', 'DAY', 'SBA', 'SBA Day Timetable', 150, 2, 'THURSDAY 26TH NOVEMBER', 'Principles of Management (HCBM)' FROM course_units cu WHERE cu.code = 'SBA' AND cu.name = 'Principles of Management' AND cu.school = 'SBA' AND cu.degree_program = 'HCBM' AND cu.year_of_study = 1 AND cu.semester = 1
UNION ALL
SELECT cu.id, '2026-11-26', '09:00:00', '12:00:00', 'NOT SPECIFIED', 'DAY', 'SBA', 'SBA Day Timetable', 151, 2, 'THURSDAY 26TH NOVEMBER', 'Introduction to Food and Nutrition (DEG)' FROM course_units cu WHERE cu.code = 'SBA' AND cu.name = 'Introduction to Food and Nutrition' AND cu.school = 'SBA' AND cu.degree_program = 'DEG' AND cu.year_of_study = 1 AND cu.semester = 1
UNION ALL
SELECT cu.id, '2026-11-26', '09:00:00', '12:00:00', 'NOT SPECIFIED', 'DAY', 'SBA', 'SBA Day Timetable', 152, 2, 'THURSDAY 26TH NOVEMBER', 'Introduction to Food and Nutrition (DIP)' FROM course_units cu WHERE cu.code = 'SBA' AND cu.name = 'Introduction to Food and Nutrition' AND cu.school = 'SBA' AND cu.degree_program = 'DIP' AND cu.year_of_study = 1 AND cu.semester = 1
UNION ALL
SELECT cu.id, '2026-11-26', '09:00:00', '12:00:00', 'NOT SPECIFIED', 'DAY', 'SBA', 'SBA Day Timetable', 153, 2, 'THURSDAY 26TH NOVEMBER', 'Food Production and Presentation (DEG)' FROM course_units cu WHERE cu.code = 'SBA' AND cu.name = 'Food Production and Presentation' AND cu.school = 'SBA' AND cu.degree_program = 'DEG' AND cu.year_of_study = 1 AND cu.semester = 1
UNION ALL
SELECT cu.id, '2026-11-26', '09:00:00', '12:00:00', 'NOT SPECIFIED', 'DAY', 'SBA', 'SBA Day Timetable', 154, 2, 'THURSDAY 26TH NOVEMBER', 'Food Production and Presentation (DIP)' FROM course_units cu WHERE cu.code = 'SBA' AND cu.name = 'Food Production and Presentation' AND cu.school = 'SBA' AND cu.degree_program = 'DIP' AND cu.year_of_study = 1 AND cu.semester = 1
UNION ALL
SELECT cu.id, '2026-11-26', '14:00:00', '17:00:00', 'NOT SPECIFIED', 'DAY', 'SBA', 'SBA Day Timetable', 155, 4, 'THURSDAY 26TH NOVEMBER', 'Advanced Accounting I (DEG)' FROM course_units cu WHERE cu.code = 'SBA' AND cu.name = 'Advanced Accounting I' AND cu.school = 'SBA' AND cu.degree_program = 'DEG' AND cu.year_of_study = 1 AND cu.semester = 1
UNION ALL
SELECT cu.id, '2026-11-26', '14:00:00', '17:00:00', 'NOT SPECIFIED', 'DAY', 'SBA', 'SBA Day Timetable', 156, 4, 'THURSDAY 26TH NOVEMBER', 'Advanced Accounting I (DIP)' FROM course_units cu WHERE cu.code = 'SBA' AND cu.name = 'Advanced Accounting I' AND cu.school = 'SBA' AND cu.degree_program = 'DIP' AND cu.year_of_study = 1 AND cu.semester = 1
UNION ALL
SELECT cu.id, '2026-11-26', '14:00:00', '17:00:00', 'NOT SPECIFIED', 'DAY', 'SBA', 'SBA Day Timetable', 157, 4, 'THURSDAY 26TH NOVEMBER', 'Procurement of Works Services and Systems (DEG)' FROM course_units cu WHERE cu.code = 'SBA' AND cu.name = 'Procurement of Works Services and Systems' AND cu.school = 'SBA' AND cu.degree_program = 'DEG' AND cu.year_of_study = 1 AND cu.semester = 1
UNION ALL
SELECT cu.id, '2026-11-26', '14:00:00', '17:00:00', 'NOT SPECIFIED', 'DAY', 'SBA', 'SBA Day Timetable', 158, 4, 'THURSDAY 26TH NOVEMBER', 'E-Clearing and Forwading (DEG)' FROM course_units cu WHERE cu.code = 'SBA' AND cu.name = 'E-Clearing and Forwading' AND cu.school = 'SBA' AND cu.degree_program = 'DEG' AND cu.year_of_study = 1 AND cu.semester = 1
UNION ALL
SELECT cu.id, '2026-11-26', '14:00:00', '17:00:00', 'NOT SPECIFIED', 'DAY', 'SBA', 'SBA Day Timetable', 159, 4, 'THURSDAY 26TH NOVEMBER', 'Information Entrepreneurship (DEG)' FROM course_units cu WHERE cu.code = 'SBA' AND cu.name = 'Information Entrepreneurship' AND cu.school = 'SBA' AND cu.degree_program = 'DEG' AND cu.year_of_study = 1 AND cu.semester = 1
UNION ALL
SELECT cu.id, '2026-11-26', '14:00:00', '17:00:00', 'NOT SPECIFIED', 'DAY', 'SBA', 'SBA Day Timetable', 160, 4, 'THURSDAY 26TH NOVEMBER', 'Fundamentals of Business Information Systems (HCBM)' FROM course_units cu WHERE cu.code = 'SBA' AND cu.name = 'Fundamentals of Business Information Systems' AND cu.school = 'SBA' AND cu.degree_program = 'HCBM' AND cu.year_of_study = 1 AND cu.semester = 1
UNION ALL
SELECT cu.id, '2026-11-26', '14:00:00', '17:00:00', 'NOT SPECIFIED', 'DAY', 'SBA', 'SBA Day Timetable', 161, 4, 'THURSDAY 26TH NOVEMBER', 'Elements of Business Finance (NBCA)' FROM course_units cu WHERE cu.code = 'SBA' AND cu.name = 'Elements of Business Finance' AND cu.school = 'SBA' AND cu.degree_program = 'NBCA' AND cu.year_of_study = 1 AND cu.semester = 1
UNION ALL
SELECT cu.id, '2026-11-26', '14:00:00', '17:00:00', 'NOT SPECIFIED', 'DAY', 'SBA', 'SBA Day Timetable', 162, 4, 'THURSDAY 26TH NOVEMBER', 'Human Resource  Competence Mapping (DEG)' FROM course_units cu WHERE cu.code = 'SBA' AND cu.name = 'Human Resource  Competence Mapping' AND cu.school = 'SBA' AND cu.degree_program = 'DEG' AND cu.year_of_study = 1 AND cu.semester = 1
UNION ALL
SELECT cu.id, '2026-11-26', '14:00:00', '17:00:00', 'NOT SPECIFIED', 'DAY', 'SBA', 'SBA Day Timetable', 163, 4, 'THURSDAY 26TH NOVEMBER', 'Wildlife and Protected Area Management (DEG)' FROM course_units cu WHERE cu.code = 'SBA' AND cu.name = 'Wildlife and Protected Area Management' AND cu.school = 'SBA' AND cu.degree_program = 'DEG' AND cu.year_of_study = 1 AND cu.semester = 1
UNION ALL
SELECT cu.id, '2026-11-27', '09:00:00', '12:00:00', 'NOT SPECIFIED', 'DAY', 'SBA', 'SBA Day Timetable', 164, 2, 'FRIDAY 27TH NOVEMBER', 'Business Startistics II (DEG)' FROM course_units cu WHERE cu.code = 'SBA' AND cu.name = 'Business Startistics II' AND cu.school = 'SBA' AND cu.degree_program = 'DEG' AND cu.year_of_study = 1 AND cu.semester = 1
UNION ALL
SELECT cu.id, '2026-11-27', '09:00:00', '12:00:00', 'NOT SPECIFIED', 'DAY', 'SBA', 'SBA Day Timetable', 165, 2, 'FRIDAY 27TH NOVEMBER', 'Marketing of Farm Produce (DEG)' FROM course_units cu WHERE cu.code = 'SBA' AND cu.name = 'Marketing of Farm Produce' AND cu.school = 'SBA' AND cu.degree_program = 'DEG' AND cu.year_of_study = 1 AND cu.semester = 1
UNION ALL
SELECT cu.id, '2026-11-27', '09:00:00', '12:00:00', 'NOT SPECIFIED', 'DAY', 'SBA', 'SBA Day Timetable', 166, 2, 'FRIDAY 27TH NOVEMBER', 'Fleet and Transport Management (DEG)' FROM course_units cu WHERE cu.code = 'SBA' AND cu.name = 'Fleet and Transport Management' AND cu.school = 'SBA' AND cu.degree_program = 'DEG' AND cu.year_of_study = 1 AND cu.semester = 1
UNION ALL
SELECT cu.id, '2026-11-27', '09:00:00', '12:00:00', 'NOT SPECIFIED', 'DAY', 'SBA', 'SBA Day Timetable', 167, 2, 'FRIDAY 27TH NOVEMBER', 'Research Methods (DEG)' FROM course_units cu WHERE cu.code = 'SBA' AND cu.name = 'Research Methods' AND cu.school = 'SBA' AND cu.degree_program = 'DEG' AND cu.year_of_study = 1 AND cu.semester = 1
UNION ALL
SELECT cu.id, '2026-11-27', '09:00:00', '12:00:00', 'NOT SPECIFIED', 'DAY', 'SBA', 'SBA Day Timetable', 168, 2, 'FRIDAY 27TH NOVEMBER', 'International Taxation (DEG)' FROM course_units cu WHERE cu.code = 'SBA' AND cu.name = 'International Taxation' AND cu.school = 'SBA' AND cu.degree_program = 'DEG' AND cu.year_of_study = 1 AND cu.semester = 1
UNION ALL
SELECT cu.id, '2026-11-27', '09:00:00', '12:00:00', 'NOT SPECIFIED', 'DAY', 'SBA', 'SBA Day Timetable', 169, 2, 'FRIDAY 27TH NOVEMBER', 'Foundations of Records Management (DEG)' FROM course_units cu WHERE cu.code = 'SBA' AND cu.name = 'Foundations of Records Management' AND cu.school = 'SBA' AND cu.degree_program = 'DEG' AND cu.year_of_study = 1 AND cu.semester = 1
UNION ALL
SELECT cu.id, '2026-11-27', '09:00:00', '12:00:00', 'NOT SPECIFIED', 'DAY', 'SBA', 'SBA Day Timetable', 170, 2, 'FRIDAY 27TH NOVEMBER', 'Foundations of Records Management (DIP)' FROM course_units cu WHERE cu.code = 'SBA' AND cu.name = 'Foundations of Records Management' AND cu.school = 'SBA' AND cu.degree_program = 'DIP' AND cu.year_of_study = 1 AND cu.semester = 1
UNION ALL
SELECT cu.id, '2026-11-27', '09:00:00', '12:00:00', 'NOT SPECIFIED', 'DAY', 'SBA', 'SBA Day Timetable', 171, 2, 'FRIDAY 27TH NOVEMBER', 'East Africa Flora Ecology (DEG)' FROM course_units cu WHERE cu.code = 'SBA' AND cu.name = 'East Africa Flora Ecology' AND cu.school = 'SBA' AND cu.degree_program = 'DEG' AND cu.year_of_study = 1 AND cu.semester = 1
UNION ALL
SELECT cu.id, '2026-11-27', '09:00:00', '12:00:00', 'NOT SPECIFIED', 'DAY', 'SBA', 'SBA Day Timetable', 172, 2, 'FRIDAY 27TH NOVEMBER', 'East Africa Flora Ecology (DIP)' FROM course_units cu WHERE cu.code = 'SBA' AND cu.name = 'East Africa Flora Ecology' AND cu.school = 'SBA' AND cu.degree_program = 'DIP' AND cu.year_of_study = 1 AND cu.semester = 1
UNION ALL
SELECT cu.id, '2026-11-27', '14:00:00', '17:00:00', 'NOT SPECIFIED', 'DAY', 'SBA', 'SBA Day Timetable', 173, 4, 'FRIDAY 27TH NOVEMBER', 'Industrial Relations (DEG)' FROM course_units cu WHERE cu.code = 'SBA' AND cu.name = 'Industrial Relations' AND cu.school = 'SBA' AND cu.degree_program = 'DEG' AND cu.year_of_study = 1 AND cu.semester = 1
UNION ALL
SELECT cu.id, '2026-11-27', '14:00:00', '17:00:00', 'NOT SPECIFIED', 'DAY', 'SBA', 'SBA Day Timetable', 174, 4, 'FRIDAY 27TH NOVEMBER', 'Industrial Relations (DIP)' FROM course_units cu WHERE cu.code = 'SBA' AND cu.name = 'Industrial Relations' AND cu.school = 'SBA' AND cu.degree_program = 'DIP' AND cu.year_of_study = 1 AND cu.semester = 1
UNION ALL
SELECT cu.id, '2026-11-27', '14:00:00', '17:00:00', 'NOT SPECIFIED', 'DAY', 'SBA', 'SBA Day Timetable', 175, 4, 'FRIDAY 27TH NOVEMBER', 'Risk and Insurance (DEG)' FROM course_units cu WHERE cu.code = 'SBA' AND cu.name = 'Risk and Insurance' AND cu.school = 'SBA' AND cu.degree_program = 'DEG' AND cu.year_of_study = 1 AND cu.semester = 1
UNION ALL
SELECT cu.id, '2026-11-27', '14:00:00', '17:00:00', 'NOT SPECIFIED', 'DAY', 'SBA', 'SBA Day Timetable', 176, 4, 'FRIDAY 27TH NOVEMBER', 'Supply Chain Management Practice (DEG)' FROM course_units cu WHERE cu.code = 'SBA' AND cu.name = 'Supply Chain Management Practice' AND cu.school = 'SBA' AND cu.degree_program = 'DEG' AND cu.year_of_study = 1 AND cu.semester = 1
UNION ALL
SELECT cu.id, '2026-11-27', '14:00:00', '17:00:00', 'NOT SPECIFIED', 'DAY', 'SBA', 'SBA Day Timetable', 177, 4, 'FRIDAY 27TH NOVEMBER', 'Performance Mgt and Assessment (DEG)' FROM course_units cu WHERE cu.code = 'SBA' AND cu.name = 'Performance Mgt and Assessment' AND cu.school = 'SBA' AND cu.degree_program = 'DEG' AND cu.year_of_study = 1 AND cu.semester = 1
UNION ALL
SELECT cu.id, '2026-11-27', '14:00:00', '17:00:00', 'NOT SPECIFIED', 'DAY', 'SBA', 'SBA Day Timetable', 178, 4, 'FRIDAY 27TH NOVEMBER', 'Disposal Management (DEG)' FROM course_units cu WHERE cu.code = 'SBA' AND cu.name = 'Disposal Management' AND cu.school = 'SBA' AND cu.degree_program = 'DEG' AND cu.year_of_study = 1 AND cu.semester = 1
UNION ALL
SELECT cu.id, '2026-11-27', '14:00:00', '17:00:00', 'NOT SPECIFIED', 'DAY', 'SBA', 'SBA Day Timetable', 179, 4, 'FRIDAY 27TH NOVEMBER', 'Tourism and Hospitality Services Management (DEG)' FROM course_units cu WHERE cu.code = 'SBA' AND cu.name = 'Tourism and Hospitality Services Management' AND cu.school = 'SBA' AND cu.degree_program = 'DEG' AND cu.year_of_study = 1 AND cu.semester = 1
UNION ALL
SELECT cu.id, '2026-11-30', '09:00:00', '12:00:00', 'NOT SPECIFIED', 'DAY', 'SBA', 'SBA Day Timetable', 180, 2, 'MONDAY 30TH NOVEMBER', 'Public Relations (DEG)' FROM course_units cu WHERE cu.code = 'SBA' AND cu.name = 'Public Relations' AND cu.school = 'SBA' AND cu.degree_program = 'DEG' AND cu.year_of_study = 1 AND cu.semester = 1
UNION ALL
SELECT cu.id, '2026-11-30', '09:00:00', '12:00:00', 'NOT SPECIFIED', 'DAY', 'SBA', 'SBA Day Timetable', 181, 2, 'MONDAY 30TH NOVEMBER', 'Public Relations (DIP)' FROM course_units cu WHERE cu.code = 'SBA' AND cu.name = 'Public Relations' AND cu.school = 'SBA' AND cu.degree_program = 'DIP' AND cu.year_of_study = 1 AND cu.semester = 1
UNION ALL
SELECT cu.id, '2026-11-30', '09:00:00', '12:00:00', 'NOT SPECIFIED', 'DAY', 'SBA', 'SBA Day Timetable', 182, 2, 'MONDAY 30TH NOVEMBER', 'Advanced Accounting II (DEG)' FROM course_units cu WHERE cu.code = 'SBA' AND cu.name = 'Advanced Accounting II' AND cu.school = 'SBA' AND cu.degree_program = 'DEG' AND cu.year_of_study = 1 AND cu.semester = 1
UNION ALL
SELECT cu.id, '2026-11-30', '09:00:00', '12:00:00', 'NOT SPECIFIED', 'DAY', 'SBA', 'SBA Day Timetable', 183, 2, 'MONDAY 30TH NOVEMBER', 'Business Communication (DEG)' FROM course_units cu WHERE cu.code = 'SBA' AND cu.name = 'Business Communication' AND cu.school = 'SBA' AND cu.degree_program = 'DEG' AND cu.year_of_study = 1 AND cu.semester = 1
UNION ALL
SELECT cu.id, '2026-11-30', '09:00:00', '12:00:00', 'NOT SPECIFIED', 'DAY', 'SBA', 'SBA Day Timetable', 184, 2, 'MONDAY 30TH NOVEMBER', 'Business Communication (DIP)' FROM course_units cu WHERE cu.code = 'SBA' AND cu.name = 'Business Communication' AND cu.school = 'SBA' AND cu.degree_program = 'DIP' AND cu.year_of_study = 1 AND cu.semester = 1
UNION ALL
SELECT cu.id, '2026-11-30', '09:00:00', '12:00:00', 'NOT SPECIFIED', 'DAY', 'SBA', 'SBA Day Timetable', 185, 2, 'MONDAY 30TH NOVEMBER', 'Information Technology (DEG)' FROM course_units cu WHERE cu.code = 'SBA' AND cu.name = 'Information Technology' AND cu.school = 'SBA' AND cu.degree_program = 'DEG' AND cu.year_of_study = 1 AND cu.semester = 1
UNION ALL
SELECT cu.id, '2026-11-30', '09:00:00', '12:00:00', 'NOT SPECIFIED', 'DAY', 'SBA', 'SBA Day Timetable', 186, 2, 'MONDAY 30TH NOVEMBER', 'Database Management Systems (DEG)' FROM course_units cu WHERE cu.code = 'SBA' AND cu.name = 'Database Management Systems' AND cu.school = 'SBA' AND cu.degree_program = 'DEG' AND cu.year_of_study = 1 AND cu.semester = 1
UNION ALL
SELECT cu.id, '2026-11-30', '09:00:00', '12:00:00', 'NOT SPECIFIED', 'DAY', 'SBA', 'SBA Day Timetable', 187, 2, 'MONDAY 30TH NOVEMBER', 'Mgt of Registries and Records Centers (DIP)' FROM course_units cu WHERE cu.code = 'SBA' AND cu.name = 'Mgt of Registries and Records Centers' AND cu.school = 'SBA' AND cu.degree_program = 'DIP' AND cu.year_of_study = 1 AND cu.semester = 1
UNION ALL
SELECT cu.id, '2026-11-30', '09:00:00', '12:00:00', 'NOT SPECIFIED', 'DAY', 'SBA', 'SBA Day Timetable', 188, 2, 'MONDAY 30TH NOVEMBER', 'Introduction to Business Law (HCBM)' FROM course_units cu WHERE cu.code = 'SBA' AND cu.name = 'Introduction to Business Law' AND cu.school = 'SBA' AND cu.degree_program = 'HCBM' AND cu.year_of_study = 1 AND cu.semester = 1
UNION ALL
SELECT cu.id, '2026-11-30', '09:00:00', '12:00:00', 'NOT SPECIFIED', 'DAY', 'SBA', 'SBA Day Timetable', 189, 2, 'MONDAY 30TH NOVEMBER', 'Food Preparation Principles II/Food Theory II (DEG)' FROM course_units cu WHERE cu.code = 'SBA' AND cu.name = 'Food Preparation Principles II/Food Theory II' AND cu.school = 'SBA' AND cu.degree_program = 'DEG' AND cu.year_of_study = 1 AND cu.semester = 1
UNION ALL
SELECT cu.id, '2026-11-30', '09:00:00', '12:00:00', 'NOT SPECIFIED', 'DAY', 'SBA', 'SBA Day Timetable', 190, 2, 'MONDAY 30TH NOVEMBER', 'Food Preparation Principles II/Food Theory II (DIP)' FROM course_units cu WHERE cu.code = 'SBA' AND cu.name = 'Food Preparation Principles II/Food Theory II' AND cu.school = 'SBA' AND cu.degree_program = 'DIP' AND cu.year_of_study = 1 AND cu.semester = 1
UNION ALL
SELECT cu.id, '2026-11-30', '14:00:00', '17:00:00', 'NOT SPECIFIED', 'DAY', 'SBA', 'SBA Day Timetable', 191, 4, 'MONDAY 30TH NOVEMBER', 'Business Finance II (DEG)' FROM course_units cu WHERE cu.code = 'SBA' AND cu.name = 'Business Finance II' AND cu.school = 'SBA' AND cu.degree_program = 'DEG' AND cu.year_of_study = 1 AND cu.semester = 1
UNION ALL
SELECT cu.id, '2026-11-30', '14:00:00', '17:00:00', 'NOT SPECIFIED', 'DAY', 'SBA', 'SBA Day Timetable', 192, 4, 'MONDAY 30TH NOVEMBER', 'Auditing and Computerised Accounting (DEG)' FROM course_units cu WHERE cu.code = 'SBA' AND cu.name = 'Auditing and Computerised Accounting' AND cu.school = 'SBA' AND cu.degree_program = 'DEG' AND cu.year_of_study = 1 AND cu.semester = 1
UNION ALL
SELECT cu.id, '2026-11-30', '14:00:00', '17:00:00', 'NOT SPECIFIED', 'DAY', 'SBA', 'SBA Day Timetable', 193, 4, 'MONDAY 30TH NOVEMBER', 'Risk Management (DEG)' FROM course_units cu WHERE cu.code = 'SBA' AND cu.name = 'Risk Management' AND cu.school = 'SBA' AND cu.degree_program = 'DEG' AND cu.year_of_study = 1 AND cu.semester = 1
UNION ALL
SELECT cu.id, '2026-11-30', '14:00:00', '17:00:00', 'NOT SPECIFIED', 'DAY', 'SBA', 'SBA Day Timetable', 194, 4, 'MONDAY 30TH NOVEMBER', 'Regional Integration and Tax Issues (DEG)' FROM course_units cu WHERE cu.code = 'SBA' AND cu.name = 'Regional Integration and Tax Issues' AND cu.school = 'SBA' AND cu.degree_program = 'DEG' AND cu.year_of_study = 1 AND cu.semester = 1
UNION ALL
SELECT cu.id, '2026-11-30', '14:00:00', '17:00:00', 'NOT SPECIFIED', 'DAY', 'SBA', 'SBA Day Timetable', 195, 4, 'MONDAY 30TH NOVEMBER', 'Office Management (DIP)' FROM course_units cu WHERE cu.code = 'SBA' AND cu.name = 'Office Management' AND cu.school = 'SBA' AND cu.degree_program = 'DIP' AND cu.year_of_study = 1 AND cu.semester = 1
UNION ALL
SELECT cu.id, '2026-11-30', '14:00:00', '17:00:00', 'NOT SPECIFIED', 'DAY', 'SBA', 'SBA Day Timetable', 196, 4, 'MONDAY 30TH NOVEMBER', 'Introduction to Economics (HCBM)' FROM course_units cu WHERE cu.code = 'SBA' AND cu.name = 'Introduction to Economics' AND cu.school = 'SBA' AND cu.degree_program = 'HCBM' AND cu.year_of_study = 1 AND cu.semester = 1
UNION ALL
SELECT cu.id, '2026-11-30', '14:00:00', '17:00:00', 'NOT SPECIFIED', 'DAY', 'SBA', 'SBA Day Timetable', 197, 4, 'MONDAY 30TH NOVEMBER', 'Project Planning & Management (DEG)' FROM course_units cu WHERE cu.code = 'SBA' AND cu.name = 'Project Planning & Management' AND cu.school = 'SBA' AND cu.degree_program = 'DEG' AND cu.year_of_study = 1 AND cu.semester = 1
UNION ALL
SELECT cu.id, '2026-11-30', '14:00:00', '17:00:00', 'NOT SPECIFIED', 'DAY', 'SBA', 'SBA Day Timetable', 198, 4, 'MONDAY 30TH NOVEMBER', 'Tourism Business Law (DEG)' FROM course_units cu WHERE cu.code = 'SBA' AND cu.name = 'Tourism Business Law' AND cu.school = 'SBA' AND cu.degree_program = 'DEG' AND cu.year_of_study = 1 AND cu.semester = 1;
