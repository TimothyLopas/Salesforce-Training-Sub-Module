*** Settings ***
Documentation     A custom resource library that allows us to pull specific fields from Salesforce
...               or add a note to a case.
Library           Collections
Library           DateTime
Library           RPA.Robocorp.Vault
Library           RPA.Salesforce
Library           RPA.Tables

*** Variables ***

*** Keywords ***
Authenticate to Salesforce
    ${sf_secret}=    Get Secret    salesforce
    Auth With Token    ${sf_secret}[api_username]    ${sf_secret}[api_password]    ${sf_secret}[api_token]

Find mailing address from case number
    [Arguments]    ${case_number}
    ${case_query}=
    ...    Salesforce Query Result As Table
    ...    SELECT Id, ContactId FROM Case WHERE CaseNumber = '${case_number}'
    ${case_id}=    Set Variable    ${case_query}[0][0]
    ${contact_id}=    Set Variable    ${case_query}[0][1]
    ${contact_query}=
    ...    Salesforce Query Result As Table
    ...    SELECT Id, MailingAddress FROM Contact WHERE Id = '${contact_id}'
    ${mailing_address_dict}=    Set Variable    ${contact_query}[0][1]
    ${mailing_address}=
    ...    Set Variable
    ...    ${mailing_address_dict}[street]${SPACE}${mailing_address_dict}[city],${SPACE}${mailing_address_dict}[state]${SPACE}${mailing_address_dict}[postalCode]
    [Return]    ${mailing_address}    ${case_id}

Append property tax details to case notes
    [Arguments]    ${latest_year_taxes}    ${assessed_value}    ${case_id}
    ${current_timestamp}=    Get Current Date    local    exclude_millis=${TRUE}
    ${note_text}=    Set Variable    2021 Taxes: ${latest_year_taxes} ${\n}2021 Assessed Value: ${assessed_value}
    ${caseFeed_data}=
    ...    Create Dictionary
    ...    ParentId=${case_id}
    ...    Body=${note_text}
    ...    Status=Published
    ...    Type=TextPost
    Create Salesforce Object    FeedItem    ${caseFeed_data}
    Log    Case Notes Updated with 2021 taxes and assessed value

Delete all case comments
    ${casecomment_query}=
    ...    Salesforce Query Result As Table
    ...    SELECT Id, CommentBody, ParentId FROM CaseComment
    FOR    ${row}    IN    @{casecomment_query}
        ${casecomment_id}=    Set Variable    ${row}[Id]
        Delete Salesforce Object    CaseComment    ${casecomment_id}
    END
