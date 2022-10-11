codeunit 50111 "TFB Contact Mgmt"
{
    trigger OnRun()
    begin

    end;

    [EventSubscriber(ObjectType::Table, Database::"To-do", 'OnCreateTaskFromSalesHeaderOnBeforeStartWizard', '', false, false)]
    local procedure OnCreateTaskFromSalesHeaderOnBeforeStartWizard(var Task: Record "To-do"; SalesHeader: Record "Sales Header");

    var
        TransText: Text[250];

    begin

        Task."TFB Sale or Purchase" := Task."TFB Sale or Purchase"::Sales;
        Task."TFB Trans. Record ID" := SalesHeader.RecordId;

        case SalesHeader."Document Type" of
            SalesHeader."Document Type"::Quote:
                TransText := StrSubstNo('Sales Quote #%1', SalesHeader."No.");
            SalesHeader."Document Type"::Order:
                TransText := StrSubstNo('Sales Order #%1', SalesHeader."No.");
            SalesHeader."Document Type"::Invoice:
                TransText := StrSubstNo('Sales Invoice #%1', SalesHeader."No.")
        end;
        Task."TFB Trans. Description" := TransText;
    end;


    [EventSubscriber(ObjectType::Report, Report::"Create Conts. from Customers", 'OnBeforeContactInsert', '', false, false)]
    local procedure OnBeforeContactInsert(Customer: Record Customer; var Contact: Record Contact);
    begin
    end;

    [EventSubscriber(ObjectType::Table, Database::Contact, 'OnAfterCreateCustomer', '', false, false)]
    local procedure OnAfterCreateCustomer(var Contact: Record Contact; var Customer: Record Customer);
    begin
    end;

    [EventSubscriber(ObjectType::Table, Database::"Interaction Log Entry", 'OnAfterCopyFromSegment', '', false, false)]
    local procedure OnAfterCopyFromSegment(var InteractionLogEntry: Record "Interaction Log Entry"; SegmentLine: Record "Segment Line");
    begin

        InteractionLogEntry."TFB Further Details" := SegmentLine."TFB Further Details";
    end;


    procedure UpdateStatusOfContacts()

    var
        Contact: Record Contact;
        StatusCurrent: Record "TFB Contact Status";
        StatusNew: Record "TFB Contact Status";
        Setup: Record "TFB Core Setup";
        Customer: Record Customer;
        Vendor: Record Vendor;
        BusRel: Record "Contact Business Relation";

    begin

        Setup.Get();

        Contact.SetRange(Type, Contact.Type::Person);
        Contact.ModifyAll("TFB Contact Status", '', false);

        Clear(Contact);

        Contact.SetRange(Type, Contact.Type::Company);

        If not Contact.FindSet(true, false) then exit;

        repeat

            BusRel.SetRange("Contact No.", contact."Company No.");
            BusRel.SetRange("Link to Table", Enum::"Contact Business Relation Link To Table"::Customer);

            If BusRel.FindFirst() then
                If Customer.Get(BusRel."No.") then begin

                    Customer.CalcFields("No. of Orders", "No. of Pstd. Invoices");

                    StatusCurrent.SetRange(Status, Contact."TFB Contact Status");

                    If not (((StatusCurrent.Probability < 1) and (StatusCurrent.Stage = StatusCurrent.Stage::Converted)) and ((Customer."No. of Orders" > 0) or (Customer."No. of Pstd. Invoices" > 0))) then
                        If (StatusCurrent.Probability < 1) and ((Customer."No. of Orders" > 0) or (Customer."No. of Pstd. Invoices" > 0)) then
                            Contact."TFB Contact Status" := Setup."Converted Status";


                end;

            BusRel.SetRange("Contact No.", contact."Company No.");
            BusRel.SetRange("Link to Table", Enum::"Contact Business Relation Link To Table"::Vendor);

            If BusRel.FindFirst() then
                If Vendor.Get(BusRel."No.") then begin

                    Vendor.CalcFields("No. of Orders", "No. of Pstd. Invoices");

                    StatusCurrent.SetRange(Status, Contact."TFB Contact Status");

                    If not (((StatusCurrent.Probability < 1) and (StatusCurrent.Stage = StatusCurrent.Stage::Converted)) and ((Vendor."No. of Orders" > 0) or (Vendor."No. of Pstd. Invoices" > 0))) then
                        If (StatusCurrent.Probability < 1) and ((Vendor."No. of Orders" > 0) or (Vendor."No. of Pstd. Invoices" > 0)) then
                            Contact."TFB Contact Status" := Setup."Converted Status";


                end;

            StatusNew.SetRange(Status, Contact."TFB Contact Status");
            If StatusNew.FindFirst() then
                Contact.Validate("TFB Contact Stage", StatusNew.Stage);
            Contact.Modify();
        until Contact.Next() = 0;
    end;
}