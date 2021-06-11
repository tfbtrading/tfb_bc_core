codeunit 50114 "TFB Sample Request Mgmt"
{
    trigger OnRun()
    begin

    end;

    var

    procedure SendSampleRequest(SampleRequest: Record "TFB Sample Request"; ReportNo: Integer): Boolean

    var

        CompanyInfo: Record "Company Information";
        SampleRequestLines: Record "TFB Sample Request Line";
        Location: Record Location;
        User: Record User;
        CommonCU: CodeUnit "TFB Common Library";
        Email: CodeUnit Email;
        EmailMessage: CodeUnit "Email Message";
        EmailAction: Enum "Email Action";
        EmailScenEnum: Enum "Email Scenario";
        BCCRecipients: List of [Text];
        CCRecipients: List of [Text];
        ContactName: Text;
        CustomerName: Text;
        EmailID: Text;
        HTMLTemplate: Text;
        Recipients: List of [Text];
        Reference2: Text;
        Reference: Text;
        SubTitleTxt: Label 'Please find a request for sample dispatch. ';
        TitleTxt: Label 'Sample Request';
        HTMLBuilder: TextBuilder;
        SubjectNameBuilder: TextBuilder;

    begin


        HTMLTemplate := CommonCU.GetHTMLTemplateActive(TitleTxt, SubTitleTxt);


        CompanyInfo.Get();

        CustomerName := Customer.Name;
        //Find first line to check for drop ship 
        SampleRequestLines.SetRange("Document No.", SampleRequest."No.");

        If SampleRequestLines.FindSet(false, false) then
            repeat
                Location :=
                Recipients.Add()

            until SampleRequestLines.Next = 0;

        //Check if drop ship

        else begin



            Location.get(SalesShipmentLine."Location Code");
            ContactName := Location.Name;
            EmailID := Location."E-Mail";
            Reference := SalesShipmentHeader."TFB 3PL Booking No.";
            Reference2 := RetrieveWhseShipReference(SalesShipmentLine."Document No.");


        end;

        //Retrieve and construct message

        SubjectNameBuilder.Append(StrSubstNo('Shipment Status Query from TFB Trading for %1 against customer reference %2', Reference, OriginalRef));
        Recipients.Add(EmailID);




        HTMLBuilder.Append(HTMLTemplate);
        //HTMLBuilder.Replace('%1', 'Shipment Status Query');
        If GenerateShipmentStatusQueryContent(ContactName, Reference, Reference2, CustomerName, HTMLBuilder) then begin

            //Check that content has been generated to send

            User.Get(UserSecurityId());
            CCRecipients.Add(User."Contact Email");


            EmailMessage.Create(Recipients, SubjectNameBuilder.ToText(), HTMLBuilder.ToText(), true, CCRecipients, BCCRecipients);
            Email.AddRelation(EmailMessage, Database::"Sales Shipment Header", SalesShipmentHeader.SystemId, Enum::"Email Relation Type"::"Primary Source");
            Email.AddRelation(EmailMessage, Database::Customer, Customer.SystemId, Enum::"Email Relation Type"::"Related Entity");
            If not (Email.OpenInEditorModally(EmailMessage, EmailScenEnum::Logistics) = EmailAction::Discarded) then begin

                CommEntry.Init();
                CommEntry."Source Type" := CommEntry."Source Type"::Customer;
                CommEntry."Source ID" := Customer."No.";
                CommEntry."Source Name" := Customer.Name;
                CommEntry."Record Type" := commEntry."Record Type"::SOC;
                CommEntry."Record Table No." := Database::"Sales Shipment Header";
                CommEntry."Record No." := SalesShipmentHeader."No.";
                CommEntry.Direction := CommEntry.Direction::Outbound;
                CommEntry.MessageContent := CopyStr(HTMLBuilder.ToText(), 1, 2048);
                CommEntry.Method := CommEntry.Method::EMAIL;
                CommEntry.Insert();

                Exit(True)
            end;
        end

    end;

        Window.Close();

    end;

    /// <summary> 
    /// Description for Setup and send a single notification
    /// </summary>
    /// <param name="RefNo">Parameter of type Code[20].</param>
    /// <returns>Return variable "Boolean".</returns>
    procedure SendOneShipmentNotificationEmail(RefNo: Code[20]): Boolean
    var
        CLib: CodeUnit "TFB Common Library";
        Window: Dialog;
        Result: Boolean;
        SubTitleTxt: Label '';
        Text001Msg: Label 'Sending Shipment Notification:\#1############################', Comment = '%1=Shipment Number';
        TitleTxt: Label 'Order Status Update';
    begin

        Window.Open(Text001Msg);
        Window.Update(1, STRSUBSTNO('%1 %2', RefNo, ''));
        Result := SendShipmentNotificationEmail(RefNo, CLib.GetHTMLTemplateActive(TitleTxt, SubTitleTxt));
        Exit(Result);
    end;

    procedure DetermineItemWarehouseLocation(Customer: Record Customer; Item: Record Item): Record Location

    var
        Location: Record Location;
        ItemLedger: Record "Item Ledger Entry";

    begin

        If Location.Get(Customer."Location Code") then begin
            ItemLedger.SetFilter("Remaining Quantity", '>0');
            ItemLedger.SetRange("Item No.", Item."No.");
            ItemLedger.SetRange("Location Code", Location.Code);


            If ItemLedger.IsEmpty() then begin
                ItemLedger.Reset();
                ItemLedger.SetFilter("Remaining Quantity", '>0');
                ItemLedger.SetRange("Item No.", Item."No.");
                If ItemLedger.FindFirst() then
                    Location.Get(ItemLedger."Location Code");
            end;


        end;
        Exit(Location);
    end;
}