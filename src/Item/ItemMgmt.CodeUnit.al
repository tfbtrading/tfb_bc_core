codeunit 50107 "TFB Item Mgmt"
{
    trigger OnRun()
    begin


    end;



    [EventSubscriber(ObjectType::Table, Database::"Sales Line", 'OnAfterCopyFromItem', '', true, true)]

    local procedure HandleOnAfterCopyFromItem(Item: Record Item; var SalesLine: Record "Sales Line")

    var


    begin
        //SalesLine.Validate("Purchasing Code", Item."TFB Default Purch. Code"); //No longer required
        UpdateDropShipSalesLineAgent(Item, SalesLine);
    end;



    procedure DownloadItemSpecification(Item: Record Item)


    var
        CommonCU: CodeUnit "TFB Common Library";
        TempBlobCU: Codeunit "Temp Blob";
        InStream: InStream;
        FileName: Text;

    begin

        TempBlobCU := CommonCU.GetSpecificationTempBlob(Item);
        TempBlobCu.CreateInStream(InStream);
        FileName := StrSubstNo('Spec For %1 (%2).pdf', Item.Description, Item."No.");
        If not DownloadFromStream(InStream, 'File Download', '', '', FileName) then
            Error('File %1 not downloaded', FileName);

    end;

    internal procedure UpdateDropShipSalesLineAgent(Item: Record Item; var SalesLine: Record "Sales Line"): Boolean

    var
        Vendor: Record Vendor;
        ShippingAgent: Record "Shipping Agent";
        AgentServices: Record "Shipping Agent Services";
        PostcodeZone: Record "TFB Postcode Zone";

    begin
        if Item.Get(SalesLine."No.") then
            if SalesLine."Drop Shipment" = true then

                //Check if there is an override shipping agent and service

                If Vendor.Get(Item."Vendor No.") then
                    If GetZoneRateForSalesLine(SalesLine, PostcodeZone) then
                        If GetVendorShippingAgentOverride(Vendor."No.", PostcodeZone.Code, AgentServices) then begin
                            SalesLine.Validate("Shipping Agent Code", AgentServices."Shipping Agent Code");
                            Salesline.validate("Shipping Agent Service Code", AgentServices.Code);
                        end
                        else
                            //if no override exists but here is a valid vendor then use default service for vendor
                            If ShippingAgent.Get(Vendor."Shipping Agent Code") then begin
                                SalesLine.Validate("Shipping Agent Code", ShippingAgent.Code);
                                Salesline.validate("Shipping Agent Service Code", ShippingAgent."TFB Service Default");
                            end;

    end;

    internal procedure DownloadItemMSDS(Item: Record Item)

    var
        InventorySetup: Record "Inventory Setup";
        CommonCU: CodeUnit "TFB Common Library";
        WordTemplate: CodeUnit "Word Template";

        InStream: InStream;
        FileName: Text;
        NoTemplateSetupMsg: Label 'No word template has been configured in inventory setup for the MSDS';
        NoRecordsSelectedMsg: Label 'No records have been selected for the merge';
    begin
        Item.SetRecFilter();
        InventorySetup.Get();
        If InventorySetup."TFB MSDS Word Template" = '' then begin
            Message(NoTemplateSetupMsg);
            exit;
        end;

        If Item.Count = 0 then begin
            Message(NoRecordsSelectedMsg);
            Exit;
        end;

        WordTemplate.Load(InventorySetup."TFB MSDS Word Template");
        If Item.Count > 1 then
            WordTemplate.Merge(Item, true, Enum::"Word Templates Save Format"::PDF)
        else
            WordTemplate.Merge(Item, false, Enum::"Word Templates Save Format"::PDF);

        WordTemplate.GetDocument(InStream);

        If Item.Count > 1 then
            FileName := StrSubstNo('MSDS Collection on %1.zip', today)
        else
            FileName := StrSubstNo('MSDS for %1 (%2).pdf', Item.Description, Item."No.");
        If not DownloadFromStream(InStream, 'File Download', '', '', FileName) then
            Error('File %1 not downloaded', FileName);
    end;

    local procedure GetZoneRateForSalesLine(SalesLine: Record "Sales Line"; var PostcodeZone: Record "TFB Postcode Zone"): Boolean

    var
        SalesHeader: Record "Sales Header";

    begin
        SalesHeader.SetRange("Document Type", SalesHeader."Document Type"::Order);
        SalesHeader.SetRange("No.", SalesLine."Document No.");

        If SalesHeader.FindFirst() then begin

            PostcodeZone.SetRange("Customer Price Group", SalesHeader."Customer Price Group");

            If PostcodeZone.FindFirst() then
                Exit(true);
        end;

    end;

    procedure GetVendorShippingAgentOverride(VendorNo: Code[20]; ShippingZone: Code[20]; var ShippingAgentService: Record "Shipping Agent Services"): Boolean

    var
        VendorZoneRate: Record "TFB Vendor Zone Rate";

    begin

        VendorZoneRate.SetRange("Sales Type", VendorZoneRate."Sales Type"::All);
        VendorZoneRate.SetRange("Zone Code", ShippingZone);
        VendorZoneRate.SetRange("Vendor No.", VendorNo);

        If VendorZoneRate.FindFirst() then
            If VendorZoneRate."Agent Service Code" <> '' then
                Exit(ShippingAgentService.Get(VendorZoneRate."Shipping Agent", VendorZoneRate."Agent Service Code"))
    end;

    procedure GetItemDynamicDetails(ItemNo: Code[20]; var SalesPrice: Decimal; var LastChanged: Date)

    var
        SalesSetup: Record "Sales & Receivables Setup";
        Item: Record Item;
        PriceListLine: Record "Price List Line";

        PricingCU: CodeUnit "TFB Pricing Calculations";
    begin
        SalesSetup.Get();

        If (SalesSetup."TFB Def. Customer Price Group" <> '') and Item.Get(ItemNo) then begin
            PriceListLine.SetRange("Asset No.", ItemNo);
            PriceListLine.SetRange("Asset Type", PriceListLine."Asset Type"::Item);
            PriceListLine.SetRange("Price Type", PriceListLine."Price Type"::Sale);
            PriceListLine.Setrange(Status, PriceListLine.Status::Active);
            PriceListLine.SetRange("Source Type", PriceListLine."Source Type"::"Customer Price Group");
            PriceListLine.SetRange("Source No.", SalesSetup."TFB Def. Customer Price Group");
            PriceListLine.SetFilter("Ending Date", '=%1|>=%2', 0D, WorkDate());


            If PriceListLine.FindLast() then begin
                SalesPrice := PricingCU.CalcPerKgFromUnit(PriceListLine."Unit Price", Item."Net Weight");
                LastChanged := PriceListLine."Starting Date";
            end;
        end;



    end;


    procedure GetItemDynamicDetails(ItemNo: Code[20]; CustNo: Code[20]; var SalesPrice: Decimal; var LastChanged: Date; var LastPricePaid: Decimal; var LastDatePurchased: Date)

    var

        SalesInvoiceLine: Record "Sales Invoice Line";
        Item: Record Item;
        PricingCU: CodeUnit "TFB Pricing Calculations";
    begin

        GetItemDynamicDetails(ItemNo, SalesPrice, LastChanged);


        SalesInvoiceLine.SetRange("Sell-to Customer No.", CustNo);
        SalesInvoiceLine.SetRange("No.", ItemNo);
        SalesInvoiceLine.SetCurrentKey("Posting Date");
        SalesInvoiceLine.SetAscending("Posting Date", false);

        If SalesInvoiceLine.FindFirst() and Item.Get(ItemNo) then begin
            LastPricePaid := PricingCU.CalcPerKgFromUnit(SalesInvoiceLine."Unit Price", SalesInvoiceLine."Net Weight");
            LastDatePurchased := SalesInvoiceLine."Posting Date";
        end;
    end;

}