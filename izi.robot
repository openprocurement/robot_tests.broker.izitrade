*** Settings ***
Library  String
Library  DateTime
Library  Selenium2Library
Library  Collections
Resource  izi_keywords.robot
Library  izi_service.py

*** Keywords ***
Login
  [Arguments]  ${username}
  Click Element  css=.login-control
  Input text  css=.login-form__email  ${USERS.users['${username}'].login}
  Input text  css=.login-form__pass  ${USERS.users['${username}'].password}
  Click Button  css=.login-form .btn_2
  Sleep  2

Підготувати дані для оголошення тендера
  [Arguments]  ${username}  ${tender_data}  ${role_name}
  [Return]  ${tender_data}

Підготувати клієнт для користувача
  [Arguments]  ${username}
  [Documentation]  Відкрити брaузер, авторизувати користувача
  &{IZI_TMP_DICT}=  Create Dictionary  &{Empty}
  Set Suite Variable  &{IZI_TMP_DICT}
  Open Browser  ${BROKERS['${BROKER}'].homepage}  ${USERS.users['${username}'].browser}  alias=${username}
  Set Window Size  @{USERS.users['${username}'].size}
  @{position}=  Create List  ${0}  ${0}
  Set Window Position  @{position}
  Run Keyword If  '${username}' != 'izi_viewer'  Login  ${username}

Пошук тендера по ідентифікатору
  [Arguments]  ${username}  ${tender_uaid}
  [Documentation]
  izi перейти на сторінку тендеру  ${tender_uaid}

Оновити сторінку з тендером
  [Arguments]  ${username}  ${tender_uaid}
  ${isAmOnPage}=  izi чи я на сторінці тендеру ${tender_uaid}
  Run Keyword If  '${isAmOnPage}' == 'FALSE'  Reload Page
  ...  ELSE  izi перейти на сторінку тендеру  ${tender_uaid}

Отримати інформацію із тендера
  [Arguments]  ${username}  ${tender_uaid}  ${field}
  izi перейти на сторінку тендеру  ${tender_uaid}
  Run Keyword And Return  izi знайти на сторінці тендера поле ${field}

Отримати інформацію із лоту
  [Arguments]  ${username}  ${tender_uaid}  ${object_id}  ${field}
  izi перейти на сторінку тендеру  ${tender_uaid}
  ${fieldPath}=  Отримати шлях до поля об’єкта  ${username}  ${field}  ${object_id}
  Run Keyword And Return  izi знайти на сторінці лоту поле ${fieldPath}

Отримати інформацію із предмету
  [Arguments]  ${username}  ${tender_uaid}  ${item_id}  ${field}
  izi перейти на сторінку тендеру  ${tender_uaid}
  ${lotsCount}=  izi get page lots count
  Run Keyword And Return If  '${lotsCount}' == '0'  izi знайти на сторінці тендера поле ${field} предмету ${item_id}
  :FOR  ${index}  IN RANGE  ${lotsCount}
  \  ${value}=  Run Keyword  izi знайти на сторінці лоту ${index} поле ${field} предмету ${item_id}
  \  Run Keyword If  "${value}" != "None"  Exit For Loop
  [Return]  ${value}

Отримати інформацію із нецінового показника
  [Arguments]  ${username}  ${tender_uaid}  ${feature_id}  ${field}
  izi перейти на сторінку тендеру  ${tender_uaid}
  ${lotsCount}=  izi get page lots count
  Run Keyword And Return If  '${lotsCount}' == '0'  izi знайти на сторінці тендера поле ${field} нецінового показника ${feature_id}
  :FOR  ${index}  IN RANGE  ${lotsCount}
  \  ${value}=  Run Keyword  izi знайти на сторінці лоту ${index} поле ${field} нецінового показника ${feature_id}
  \  Run Keyword If  "${value}" != "None"  Exit For Loop
  [Return]  ${value}

Задати запитання на тендер
  [Arguments]  ${username}  ${tender_uaid}  ${question}
  izi перейти на сторінку тендеру  ${tender_uaid}
  izi задати запитання на тендер  ${question}

Задати запитання на лот
  [Arguments]  ${username}  ${tender_uaid}  ${lotObjectId}  ${question}
  izi перейти на сторінку тендеру  ${tender_uaid}
  izi задати запитання на лот  ${lotObjectId}  ${question}

Задати запитання на предмет
  [Arguments]  ${username}  ${tender_uaid}  ${item_id}  ${question}
  izi перейти на сторінку тендеру  ${tender_uaid}
  izi задати запитання на предмет  ${item_id}  ${question}

Отримати інформацію із запитання
  [Arguments]  ${username}  ${tender_uaid}  ${question_id}  ${field}
  izi перейти на сторінку тендеру  ${tender_uaid}
  Run Keyword And Return  izi знайти на сторінці тендеру запитання ${question_id} поле ${field}

Відповісти на запитання
  [Arguments]  ${tender_uaid}  ${answer_data}  ${question_id}
  openprocurement_client.Відповісти на запитання  ${tender_uaid}  ${answer_data}  ${question_id}

Завантажити документ
  [Arguments]  ${file_path}  ${tender_uaid}
  openprocurement_client.Завантажити документ  ${file_path}  ${tender_uaid}

Завантажити документ в лот
  [Arguments]  ${file_path}  ${tender_uaid}  ${lot_id}
  openprocurement_client.Завантажити документ в лот  ${file_path}  ${tender_uaid} ${lot_id}

Отримати документ
  [Arguments]  ${username}  ${tender_uaid}  ${doc_id}
  izi перейти на сторінку тендеру  ${tender_uaid}
  ${url}=  Run Keyword  izi знайти на сторінці тендера поле ulr документу ${doc_id}
  ${title}=  Run Keyword  izi знайти на сторінці тендера поле title документу ${doc_id}
  ${filename}=  download_file_from_url  ${url}  ${OUTPUT_DIR}${/}${title}
  [Return]  ${filename}

Отримати документ до лоту
  [Arguments]  ${username}  ${tender_uaid}  ${lot_object_id}  ${doc_id}
  izi перейти на сторінку тендеру  ${tender_uaid}
  ${index}=  izi знайти index лоту за lotObjectId  ${lot_object_id}
  ${url}=  Run Keyword  izi знайти на сторінці лоту ${index} поле ulr документу ${doc_id}
  ${title}=  Run Keyword  izi знайти на сторінці тендера поле title документу ${doc_id}
  ${filename}=  download_file_from_url  ${url}  ${OUTPUT_DIR}${/}${title}
  [Return]  ${filename}

Отримати інформацію із документа
  [Arguments]  ${username}  ${tender_uaid}  ${doc_id}  ${field}
  izi update tender  ${tender_uaid}
  izi перейти на сторінку тендеру  ${tender_uaid}
  ${value}=  Run Keyword  izi знайти на сторінці тендера поле ${field} документу ${doc_id}
  Return From Keyword If  "${value}" != "None"  ${value}
  ${lotsCount}=  izi get page lots count
  :FOR  ${index}  IN RANGE  ${lotsCount}
  \  ${value}=  Run Keyword  izi знайти на сторінці лоту ${index} поле ${field} документу ${doc_id}
  \  Run Keyword If  "${value}" != "None"  Exit For Loop
  [Return]  ${value}

Отримати інформацію із документа до скарги
  [Arguments]  ${username}  ${tender_uaid}  ${complaintID}  ${doc_id}  ${field}
  izi update tender  ${tender_uaid}
  izi перейти на сторінку тендеру  ${tender_uaid}
  ${value}=  Run Keyword  izi знайти поле ${field} документу ${doc_id} вимоги ${complaintID}
  [Return]  ${value}

Створити постачальника, додати документацію і підтвердити його
  [Arguments]  ${username}  ${tender_uaid}  ${supplier_data}  ${document}
  openprocurement_client.Створити постачальника, додати документацію і підтвердити його  ${username}  ${tender_uaid}  ${supplier_data}  ${document}

Підтвердити підписання контракту
  [Arguments]  ${username}  ${tender_uaid}  ${contract_num}
  openprocurement_client.Підтвердити підписання контракту  ${username}  ${tender_uaid}  ${contract_num}

Створити вимогу про виправлення умов закупівлі
  [Arguments]  ${username}  ${tender_uaid}  ${claim}  ${document}
  izi перейти на сторінку тендеру  ${tender_uaid}
  ${complaintID}=  izi створити вимогу про виправлення умов тендера  ${tender_uaid}  ${claim}  ${document}
  izi update tender  ${tender_uaid}
  [Return]  ${complaintID}

Створити вимогу про виправлення умов лоту
  [Arguments]  ${username}  ${tender_uaid}  ${claim}  ${lot_id}  ${document_path}
  izi перейти на сторінку тендеру  ${tender_uaid}
  ${complaintID}=  izi cтворити вимогу про виправлення умов лоту  ${tender_uaid}  ${lot_id}  ${claim}  ${document_path}
  izi update tender  ${tender_uaid}
  [Return]  ${complaintID}

Створити чернетку вимоги про виправлення умов закупівлі
  [Arguments]  ${username}  ${tender_uaid}  ${claim}
  izi перейти на сторінку тендеру  ${tender_uaid}
  ${complaintID}=  izi створити чернетку вимоги про виправлелння умов закупівлі  ${tender_uaid}  ${claim}
  izi update tender  ${tender_uaid}
  [Return]  ${complaintID}

Створити чернетку вимоги про виправлення умов лоту
  [Arguments]  ${username}  ${tender_uaid}  ${claim}  ${lot_id}
  izi перейти на сторінку тендеру  ${tender_uaid}
  ${complaintID}=  izi створити чернетку вимоги про виправлення умов лоту  ${tender_uaid}  ${claim}  ${lot_id}
  izi update tender  ${tender_uaid}
  [Return]  ${complaintID}

Відповісти на вимогу про виправлення умов закупівлі
  [Arguments]  ${username}  ${tender_uaid}  ${complaintID}  ${answer_data}
  openprocurement_client.Відповісти на вимогу про виправлення умов закупівлі  ${username}  ${tender_uaid}  ${complaintID}  ${answer_data}

Відповісти на вимогу про виправлення умов лоту
  [Arguments]  ${username}  ${tender_uaid}  ${complaintID}  ${answer_data}
  openprocurement_client.Відповісти на вимогу про виправлення умов лоту  ${username}  ${tender_uaid}  ${complaintID}  ${answer_data}

Отримати інформацію із скарги
  [Arguments]  ${username}  ${tender_uaid}  ${complaintID}  ${field_name}  ${award_index}
  izi перейти на сторінку тендеру  ${tender_uaid}
  Run Keyword And Return If  'status' == '${field_name}'  izi отримати поле status з вимоги  ${complaintID}
  Run Keyword And Return If  'description' == '${field_name}'  izi отримати поле description з вимоги  ${complaintID}
  Run Keyword And Return If  'title' == '${field_name}'  izi отримати поле title з вимоги  ${complaintID}
  Run Keyword And Return If  'resolutionType' == '${field_name}'  izi отримати поле resolutionType з вимоги  ${complaintID}
  Run Keyword And Return If  'resolution' == '${field_name}'  izi отримати поле resolution з вимоги  ${complaintID}
  Run Keyword And Return If  'satisfied' == '${field_name}'  izi отримати поле satisfied з вимоги  ${complaintID}
  Run Keyword And Return If  'cancellationReason' == '${field_name}'  izi отримати поле cancellationReason з вимоги  ${complaintID}

Підтвердити вирішення вимоги про виправлення умов закупівлі
  [Arguments]  ${username}  ${tender_uaid}  ${complaintID}  ${confirmation_data}
  izi update tender  ${tender_uaid}
  izi перейти на сторінку тендеру  ${tender_uaid}
  izi підтвердити\заперечити вирішення вимоги про виправлення умов закупівлі  ${complaintID}  ${confirmation_data}  ${tender_uaid}

Підтвердити вирішення вимоги про виправлення умов лоту
  [Arguments]  ${username}  ${tender_uaid}  ${complaintID}  ${confirmation_data}
  izi.Підтвердити вирішення вимоги про виправлення умов закупівлі  ${username}  ${tender_uaid}  ${complaintID}  ${confirmation_data}

Скасувати вимогу про виправлення умов закупівлі
  [Arguments]  ${username}  ${tender_uaid}  ${complaintID}  ${cancellation_data}
  izi перейти на сторінку тендеру  ${tender_uaid}
  izi cкасувати вимогу до лоту або закупівлі  ${tender_uaid}  ${complaintID}  ${cancellation_data}

Скасувати вимогу про виправлення умов лоту
  [Arguments]  ${username}  ${tender_uaid}  ${complaintID}  ${cancellation_data}
  izi.Скасувати вимогу про виправлення умов закупівлі  ${username}  ${tender_uaid}  ${complaintID}  ${cancellation_data}

Створити вимогу про виправлення визначення переможця
  [Arguments]  ${username}  ${tender_uaid}  ${claim}  ${award_index}  ${document}
  izi перейти на сторінку тендеру  ${tender_uaid}
  ${complaintID}=  izi створити вимогу про виправлення визначення переможця  ${tender_uaid}  ${claim}  ${award_index}  ${document}
  [Return]  ${complaintID}

Подати цінову пропозицію
  [Arguments]  ${username}  ${tender_uaid}  ${bid}  ${lotsObjectIds}=@{Empty}  ${featuresObjectIds}=${None}
  izi перейти на сторінку тендеру  ${tender_uaid}
  ${bid.data.parameters}=  Get Variable Value  ${bid.data['parameters']}  @{EMPTY}
  ${bid.data.value.amount}=  izi знайти на сторінці тендера поле value.amount
  ${lotsObjectCount}=  Run Keyword If  "${lotsObjectIds}" == "None"  Set Variable  0
  ...  ELSE  Get Length  ${lotsObjectIds}
  Run Keyword And Return If  '${lotsObjectCount}' == '0'  izi подати цінову пропозицію на тендер  bid=${bid}
  :FOR  ${lotObjectId}  IN  @{lotsObjectIds}
  \  ${lotIndex}=  izi знайти index лоту за lotObjectId  ${lotObjectId}
  \  ${bid.data.value}=  Set Variable  ${bid.data.lotValues[${lotIndex}].value}
  \  ${bid.data.value.amount}=  izi знайти на сторінці лоту ${lotIndex} поле value.amount
  \  Run Keyword  izi подати цінову пропозицію на тендер  lotIndex=${lotIndex}  bid=${bid}

Скасувати цінову пропозицію
  [Arguments]  ${username}  ${tender_uaid}
  izi перейти на сторінку тендеру  ${tender_uaid}
  ${lotsCount}=  izi get page lots count
  Run Keyword And Return If  '${lotsCount}' == '0'  izi скасувати цінову пропозицію на тендер
  Run Keyword And Return  izi скасувати цінову пропозицію на лот  lotIndex=0

Отримати інформацію із пропозиції
  [Arguments]  ${username}  ${tender_uaid}  ${field}
  izi перейти на сторінку тендеру  ${tender_uaid}
  Run Keyword And Return  izi знайти на сторінці тендера поле пропозиції ${field}

Змінити цінову пропозицію
  [Arguments]  ${username}  ${tender_uaid}  ${fieldname}  ${fieldvalue}
  izi перейти на сторінку тендеру  ${tender_uaid}
  Run Keyword And Return  izi змінити на сторінці тендера поле пропозиції ${fieldname} на ${fieldvalue}

Завантажити документ в ставку
  [Arguments]  ${username}  ${filePath}  ${tender_uaid}  ${prozorro_documentType}=technicalSpecifications
  izi перейти на сторінку тендеру  ${tender_uaid}
  ${docType}=  izi_service.get_izi_docType_by_prozorro_docType  ${prozorro_documentType}
  ${lotsCount}=  izi get page lots count
  Run Keyword And Return If  '${lotsCount}' == '0'  izi дозавантажити документ до пропозиції тендера  filePath=${filePath}  docType=${docType}
  Run Keyword And Return  izi дозавантажити документ до пропозиції лота  lotIndex=0  filePath=${filePath}  docType=${docType}

Змінити документ в ставці
  [Arguments]  ${username}  ${tender_uaid}  ${filePath}  ${docObjectId}  ${prozorro_documentType}=technicalSpecifications
  izi перейти на сторінку тендеру  ${tender_uaid}
  ${docType}=  izi_service.get_izi_docType_by_prozorro_docType  ${prozorro_documentType}
  ${lotsCount}=  izi get page lots count
  Run Keyword And Return If  '${lotsCount}' == '0'  izi замінити документ в пропозиції тендера  docObjectId=${docObjectId}  filePath=${filePath}  docType=${docType}
  Run Keyword  izi замінити документ в пропозиції лота  lotIndex=0  docObjectId=${docObjectId}  filePath=${filePath}  docType=${docType}

Змінити документацію в ставці
  [Arguments]  ${username}  ${tender_uaid}  ${docData}  ${docObjectId}
  izi перейти на сторінку тендеру  ${tender_uaid}
  ${lotsCount}=  izi get page lots count
  Run Keyword And Return If  '${lotsCount}' == '0'  izi змінити документ в пропозиції тендера  docObjectId=${docObjectId}  docData=${docData}
  Run Keyword  izi змінити документ в пропозиції лота  lotIndex=0  docObjectId=${docObjectId}  docData=${docData}

Завантажити документ у кваліфікацію
  [Arguments]  ${username}  ${document}  ${tender_uaid}  ${qualification_num}
  Run Keyword And Return  openprocurement_client.Завантажити документ у кваліфікацію  ${username}  ${document}  ${tender_uaid}  ${qualification_num}

Завантажити документ рішення кваліфікаційної комісії
  [Arguments]  ${username}  ${document}  ${tender_uaid}  ${award_num}
  openprocurement_client.Завантажити документ рішення кваліфікаційної комісії  ${username}  ${document}  ${tender_uaid}  ${award_num}

Підтвердити постачальника
  [Arguments]  ${username}  ${tender_uaid}  ${award_num}
  openprocurement_client.Підтвердити постачальника  ${username}  ${document}  ${tender_uaid}  ${award_num}

Підтвердити вирішення вимоги про виправлення визначення переможця
  [Arguments]  ${username}  ${tender_uaid}  ${complaintID}  ${confirmation_data}  ${award_index}
  izi перейти на сторінку тендеру  ${tender_uaid}
  izi підтвердити вирішення вимоги про виправлення визначення переможця  ${tender_uaid}  ${complaintID}  ${confirmation_data}  ${award_index}

Створити чернетку вимоги про виправлення визначення переможця
  [Arguments]  ${username}  ${tender_uaid}  ${claim}  ${award_index}
  izi перейти на сторінку тендеру  ${tender_uaid}
  ${complaintID}=  izi створити чернетку вимоги про виправлення визначення переможця  ${tender_uaid}  ${claim}  ${award_index}
  izi update tender  ${tender_uaid}
  [Return]  ${complaintID}

Скасувати вимогу про виправлення визначення переможця
  [Arguments]  ${username}  ${tender_uaid}  ${complaintID}  ${cancellation_data}  ${award_index}
  izi перейти на сторінку тендеру  ${tender_uaid}
  izi cкасувати вимогу до лоту або закупівлі  ${tender_uaid}  ${complaintID}  ${cancellation_data}  ${award_index}

Внести зміни в тендер
  [Arguments]  ${username}  ${tender_uaid}  ${fieldname}  ${fieldvalue}
  openprocurement_client.Внести зміни в тендер  ${username}  ${tender_uaid}  ${fieldname}  ${fieldvalue}

Отримати посилання на аукціон для учасника
  [Arguments]  ${username}  ${tender_uaid}  ${lotObjectId}=${None}
  izi перейти на сторінку тендеру  ${tender_uaid}
  Run Keyword And Return If  '${lotObjectId}' == '${None}'  izi знайти на сторінці тендера посилання на аукціон
  ${lotIndex}=  izi знайти index лоту за lotObjectId  ${lotObjectId}
  Run Keyword And Return  izi знайти на сторінці лоту ${lotIndex} посилання на аукціон

Отримати посилання на аукціон для глядача
  [Arguments]  ${username}  ${tender_uaid}  ${lotObjectId}=${None}
  izi перейти на сторінку тендеру  ${tender_uaid}
  Run Keyword And Return If  '${lotObjectId}' == '${None}'  izi знайти на сторінці тендера посилання на аукціон
  ${lotIndex}=  izi знайти index лоту за lotObjectId  ${lotObjectId}
  Run Keyword And Return  izi знайти на сторінці лоту ${lotIndex} посилання на аукціон