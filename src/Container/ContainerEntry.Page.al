page 50210 "TFB Container Entry"
{
    PageType = Document;
    SourceTable = "TFB Container Entry";
    Caption = 'Inbound Shipment';
    PromotedActionCategories = 'Navigation';
    UsageCategory = None;

    layout
    {
        area(Content)
        {
            group("General")
            {
                Caption = 'General';



                group("ShipmentDetails")
                {
                    Caption = 'Shipment Details';


                    field("No."; Rec."No.")
                    {

                        ApplicationArea = All;
                        ShowMandatory = true;
                        Importance = Promoted;
                        ToolTip = 'Specifies no. for container entry';


                        trigger OnAssistEdit()

                        var
                            PurchaseSetup: record "Purchases & Payables Setup";

                        begin

                            PurchaseSetup.TestField("TFB Container Entry Nos.");

                            If NoSeriesMgt.SelectSeries(PurchaseSetup."TFB Container Entry Nos.", xRec."No. Series", Rec."No. Series") then
                                NoSeriesMgt.SetSeries(Rec."No.");

                        end;

                    }
                    field("Shipper"; Rec."Vendor No.")
                    {
                        ApplicationArea = All;
                        Importance = Promoted;
                        ToolTip = 'Specifies vendor no.';

                        trigger OnValidate()

                        begin
                            LoadTempTable();
                        end;



                    }
                    field("Vendor Name"; Rec."Vendor Name")
                    {
                        ApplicationArea = All;
                        Lookup = true;
                        LookupPageId = "Vendor List";
                        ToolTip = 'Specifies vendor name';

                        trigger OnValidate()

                        begin
                            LoadTempTable();
                        end;


                    }


                    field("Type"; Rec."Type")
                    {
                        ApplicationArea = All;
                        Importance = Promoted;
                        ToolTip = 'Specifies type of container entry';

                        trigger OnValidate()
                        begin

                            isVisible := false;
                            CurrPage.Lines.Page.SetVisibilityType(isVisible);


                            LoadTempTable();
                        end;

                    }

                    field("Order Reference"; Rec."Order Reference")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies order reference for container entry';


                        trigger OnValidate()

                        begin

                            LoadTempTable();
                        end;
                    }

                    group(PurchaseDetails)
                    {
                        ShowCaption = false;
                        Visible = not isVisible;
                        field("Landed Cost Template"; Rec."Landed Cost Template")
                        {
                            ApplicationArea = All;

                            Tooltip = 'Specifies landed cost template for container';

                            trigger OnValidate()

                            begin
                                if (Rec."Landed Cost Template" <> '') and (Rec."Order Reference" <> '') then
                                    LoadTempTable();
                            end;
                        }

                    }
                    group(ShippedFromPort)
                    {
                        ShowCaption = false;
                        Visible = Rec."Qty. On Purch. Rcpt" > 0;

                        field("Qty. On Purch. Rcpt"; Rec."Qty. On Purch. Rcpt")
                        {
                            ApplicationArea = All;
                            Editable = false;
                            DrillDown = true;
                            DrillDownPageId = "Purch. Receipt Lines";
                            ToolTip = 'Specifies qty on rcpt';
                        }
                        Field("Qty. On Transfer Order"; Rec."Qty. On Transfer Order")
                        {
                            ApplicationArea = All;
                            Editable = false;
                            DrillDown = true;
                            DrillDownPageId = "Transfer Order";
                            ToolTip = 'Specifies qty on transfer order';
                        }
                        field("Qty. On Transfer Ship."; Rec."Qty. On Transfer Ship.")
                        {
                            ApplicationArea = All;
                            Editable = false;
                            DrillDown = true;
                            DrillDownPageId = "Posted Transfer Shipment Lines";
                            ToolTip = 'Specifies qty on transfer shipment';

                        }



                    }
                    group(Received)
                    {
                        ShowCaption = False;
                        Visible = Rec."Qty. On Transfer Rcpt" > 0;
                        field("Qty. On Transfer Rcpt"; Rec."Qty. On Transfer Rcpt")
                        {
                            ApplicationArea = All;
                            Editable = false;
                            ToolTip = 'Specifies qty on Transfer Rcpt';
                        }
                    }


                }
                group("ShipmentTracking")
                {
                    Caption = 'Tracking Details';

                    field("Status"; Rec."Status")
                    {
                        ApplicationArea = All;
                        Importance = Promoted;
                        ToolTip = 'Specifies current status of container';
                    }
                    field("% Sold"; _PercReserved)
                    {
                        ApplicationArea = All;
                        Caption = '% Sold';
                        Editable = false;
                        ToolTip = 'Specifies the percentage of container contents sold';
                        AutoFormatType = 10;
                        AutoFormatExpression = '<precision, 1:1><standard format,0>%';
                    }
                    field("Ship Via"; Rec."Ship Via")
                    {
                        ApplicationArea = All;
                        Importance = Promoted;
                        Lookup = true;
                        ToolTip = 'Specifies ship via for container';

                    }

                    field("Shipping Line"; Rec."Shipping Line")
                    {
                        ApplicationArea = All;
                        Importance = Additional;
                        ToolTip = 'Specifies shipping line';
                    }
                    field("Booking Reference"; Rec."Booking Reference")
                    {
                        ApplicationArea = All;
                        Importance = Additional;
                        Tooltip = 'Specifies booking reference';
                    }

                    field("Vessel Details"; Rec."Vessel Details")
                    {
                        ApplicationArea = All;
                        Importance = Promoted;
                        Tooltip = 'Specifies vessel details';
                    }

                    field("Container No."; Rec."Container No.")
                    {
                        ApplicationArea = All;
                        ShowMandatory = true;
                        Importance = Promoted;
                        Tooltip = 'Specifies container no.';
                    }
                    field("Quarantine Reference"; Rec."Quarantine Reference")
                    {
                        ApplicationArea = All;
                        Importance = Promoted;
                        Tooltip = 'Specifies quarantine reference';
                    }


                    group(AQIS)
                    {
                        grid(NEW)
                        {
                            GridLayout = Columns;
                            ShowCaption = false;

                            field("Inspection Req."; Rec."Inspection Req.")
                            {
                                ApplicationArea = All;
                                Tooltip = 'Specifies if inspection is required';

                                trigger OnValidate()

                                begin
                                    CheckAqisReq()
                                end;

                            }
                            field("Fumigation Req."; Rec."Fumigation Req.")
                            {
                                ApplicationArea = All;
                                Tooltip = 'Specifies if fumigation is required';

                                trigger OnValidate()

                                begin
                                    CheckAqisReq()
                                end;

                            }
                            field("IFIP Req."; Rec."IFIP Req.")
                            {
                                ApplicationArea = All;
                                Tooltip = 'Specifies if imported food program inspection required';

                                trigger OnValidate()

                                begin
                                    CheckAqisReq()
                                end;

                            }

                            field("Heat Treat. Req."; Rec."Heat Treat. Req.")
                            {
                                ApplicationArea = All;
                                ToolTip = 'Specifies if heat treatment is required';

                                trigger OnValidate()

                                begin
                                    CheckAqisReq();
                                end;
                            }
                        }


                        field("Unpack Report Attach."; _unpackReportAttached)
                        {
                            ApplicationArea = All;
                            AssistEdit = false;
                            Caption = 'Unpack Report Attached';
                            Editable = false;
                            Tooltip = 'Specifies if unpack report for container is attached';





                        }


                    }

                }
            }
            group("Tracking")
            {
                group("Estimated")
                {
                    field("Est. Departure Date"; Rec."Est. Departure Date")
                    {

                        ApplicationArea = All;
                        Importance = Promoted;
                        ToolTip = 'Specifies est. depature date';

                    }
                    field("Est. Arrival Date"; Rec."Est. Arrival Date") { ApplicationArea = All; Importance = Promoted; Tooltip = 'Specifies est. arrival date'; }
                    field("Est. Clear Date"; Rec."Est. Clear Date") { ApplicationArea = All; Tooltip = 'Specifies est. clear date'; }
                    field("Est. Warehouse"; Rec."Est. Warehouse") { ApplicationArea = All; Importance = Promoted; Tooltip = 'Specifies est. date in warehouse'; }
                    field("Est. Return Cutoff"; Rec."Est. Return Cutoff") { ApplicationArea = All; Tooltip = 'Specifies return cutoff date for container'; }
                }
                group("Actuals")
                {
                    field("Departure Date"; Rec."Departure Date") { ApplicationArea = All; ToolTip = 'Specifies actual date of bill of lading'; }
                    field("Arrival Date"; Rec."Arrival Date") { ApplicationArea = All; Tooltip = 'Specifies actual arrival date'; }

                    field("Clear Date"; Rec."Clear Date") { ApplicationArea = All; Tooltip = 'Specifies clearance date'; }

                    group(Fumigation)
                    {
                        Visible = Rec."Fumigation Req.";
                        ShowCaption = false;

                        field("Fumigation Date"; Rec."Fumigation Date")
                        {
                            ApplicationArea = All;
                            Tooltip = 'Specifies date container entered fumigation';
                        }
                        field("Fumigation Release Date"; Rec."Fumigation Release Date")
                        {
                            ApplicationArea = All;
                            Tooltip = 'Specifies fumigation release date';
                        }


                    }
                    group(Inspection)
                    {
                        Visible = Rec."Inspection Req." or Rec."IFIP Req.";
                        ShowCaption = false;


                        field("Inspection Date"; Rec."Inspection Date")
                        {
                            ApplicationArea = All;
                            Tooltip = 'Specifies date container is booked to be inspected';
                        }

                    }

                    group(HT)
                    {
                        Visible = Rec."Heat Treat. Req.";
                        ShowCaption = false;


                        field("Heat Treatment Date"; Rec."Heat Treatment Date")
                        {
                            ApplicationArea = All;
                            Tooltip = 'Specifies date container is booked in for heat treatment';
                        }

                    }
                    field("Warehouse Date"; Rec."Warehouse Date") { ApplicationArea = All; Tooltip = 'Specifies date container is available to sell'; }
                    field("Container Returned"; Rec."Container Returned") { ApplicationArea = All; Tooltip = 'Specifies date container returned'; }
                }
            }
            part(Lines; "TFB Container Entry SubForm")
            {
                Visible = true;
                ApplicationArea = All;
                Caption = 'Lines';

            }
        }


        area(FactBoxes)
        {

            systempart("Notes"; Notes)
            {
                ApplicationArea = All;

            }
            part(ItemPicture; "Item Picture")
            {
                ApplicationArea = All;
                Provider = Lines;
                SubPageLink = "No." = field("Item Code");
            }




        }
    }




    actions
    {
        area(Processing)
        {
            action("TFBSendWarehouseUpdate")
            {
                ApplicationArea = All;
                Promoted = true;
                PromotedIsBig = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                Image = SendConfirmation;
                Enabled = Rec."Quarantine Reference" <> '';
                Caption = 'Send Update to Warehouse';
                ToolTip = 'Sends update for container to warehouse';

                trigger OnAction()

                begin
                    SendWarehouseUpdateEmail(Rec."No.");
                end;
            }
            action("Upload unpack report")
            {
                ApplicationArea = All;
                Image = ExternalDocument;
                Promoted = true;
                PromotedIsBig = true;
                PromotedCategory = Process;

                Tooltip = 'Uploads a pdf attachement for unpack report';

                trigger onAction()

                begin
                    if _unpackReportAttached then
                        if not Dialog.Confirm('Overwrite attached file?') then
                            exit;
                    AttachFile();
                end;
            }

            action("Download Unpack Report")
            {
                ApplicationArea = All;
                Image = ElectronicDoc;
                Promoted = true;
                PromotedIsBig = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                Enabled = _unpackReportAttached;
                Tooltip = 'Downloads a pdf attachment if it exists';


                trigger OnAction()
                begin

                    DownloadFile();

                end;
            }

            action("Adjust Reserved Sales")
            {
                ApplicationArea = All;
                Image = AdjustEntries;
                Promoted = true;
                PromotedIsBig = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                Enabled = Rec."Qty. On Purch. Rcpt" > 0;
                ToolTip = 'Aligns sales lines reserved from container to incoming container date';

                trigger OnAction()

                begin
                    AdjustReservedSales();
                end;
            }


        }
        area(Navigation)
        {

            action("Order")
            {
                ApplicationArea = All;
                Image = Order;
                Promoted = true;
                PromotedIsBig = true;
                PromotedOnly = true;
                Tooltip = 'Navigate to purchase order';

                trigger OnAction()

                var

                    recPurchaseHeader: record "Purchase Header";

                begin

                    case Rec.Type of
                        Rec.Type::"PurchaseOrder":
                            begin
                                recPurchaseHeader.Init();
                                recPurchaseHeader.SetRange("Document Type", recPurchaseHeader."Document Type"::Order);
                                recPurchaseHeader.SetRange("No.", Rec."Order Reference");

                                if recPurchaseHeader.FindFirst() then begin
                                    pagePurchaseHead.SetTableView(recPurchaseHeader);
                                    pagePurchaseHead.GetRecord(recPurchaseHeader);
                                    pagePurchaseHead.Editable(true);

                                    pagePurchaseHead.Run();
                                end;
                            end;


                    end;


                end;
            }

            action("Vendor")
            {
                ApplicationArea = All;
                Promoted = true;
                PromotedOnly = true;
                PromotedIsBig = true;
                Image = Vendor;
                RunObject = page "Vendor Card";
                RunPageMode = Edit;
                RunPageLink = "No." = field("Vendor No.");
                Tooltip = 'Navigate to related vendor';

                trigger OnAction()
                begin

                end;
            }


            action("Purchase Receipt")
            {
                ApplicationArea = All;

                Caption = 'Purchase receipt';
                Tooltip = 'Navigate to purchase receipt';
                Image = Receipt;
                RunObject = page "Posted Purchase Receipt Lines";
                RunPageMode = view;
                RunPageLink = "TFB Container Entry No." = field("No.");
                Enabled = (Rec."Qty. On Purch. Rcpt" > 0);

                trigger OnAction()
                begin

                end;
            }
            action("Transfer")
            {
                ApplicationArea = All;
                Tooltip = 'Navigate to transfer order';

                Image = Vendor;
                RunObject = page "Transfer Orders";
                RunPageMode = edit;
                RunPageLink = "TFB Container Entry No." = field("No.");
                Enabled = (Rec."Qty. On Transfer Order" > 0);

                trigger OnAction()
                begin

                end;
            }
        }


    }

    var
        NoSeriesMgt: Codeunit NoSeriesManagement;

        ContainerCU: Codeunit "TFB Container Mgmt";
        pagePurchaseHead: Page "Purchase Order";



        _PercReserved, _QtyOnOrder, _QtyReserved : Decimal;
        _unpackReportAttached, isAQISRelevant, isVisible : Boolean;

    local procedure AttachFile()

    var

        TempBlobCU: Codeunit "Temp Blob";
        PersistBlobCU: CodeUnit "Persistent Blob";

        FilterTxt: Label 'All files (*.pdf)|*.pdf';
        EmptyFileNameErr: Label 'No content';
        FileDialogTxt: Label 'Select Container Unpack File to Upload';
        FileName: Text;
        IStream: InStream;

        BlobRef: BigInteger;


    begin


        TempBlobCU.CreateInStream(IStream);

        FileName := StrSubstNo('Unpack_%1.pdf', Rec."Container No.");
        if UploadIntoStream(FileDialogTxt, '', FilterTxt, FileName, IStream) then begin
            If (FileName <> '') and TempBlobCU.HasValue() then
                Error(EmptyFileNameErr);

            BlobRef := PersistBlobCU.Create();
            If PersistBlobCU.CopyFromInStream(BlobRef, IStream) then
                Rec."Unpack Worksheet Attach." := BlobRef;

            rec.Modify();

        end;

        UpdateReportStatus();
    end;


    local procedure DownloadFile()

    var

        PersistentBlob: Codeunit "Persistent Blob";
        TempBlob: CodeUnit "Temp Blob";
        FileNameBuilder: TextBuilder;
        FileName: Text;
        InStream: InStream;
        OutStream: OutStream;

    begin


        If Rec."Unpack Worksheet Attach." > 0 then
            If PersistentBlob.Exists(Rec."Unpack Worksheet Attach.") then begin
                FileNameBuilder.Append('UnpackReport_');
                FileNameBuilder.Append(Rec."Container No.");
                FileNameBuilder.Append('.pdf');
                FileName := FileNameBuilder.ToText();
                TempBlob.CreateInStream(InStream);
                TempBlob.CreateOutStream(OutStream);
                PersistentBlob.CopyToOutStream(Rec."Unpack Worksheet Attach.", OutStream);
                CopyStream(OutStream, InStream);
                If Not DownloadFromStream(InStream, 'Title', 'ToFolder', 'Filter', FileName) then
                    Error('File Not Downloaded');
            end;
    end;

    local procedure RemoveFile()
    var
        PersistentBlob: Codeunit "Persistent Blob";
    begin

        If Rec."Unpack Worksheet Attach." > 0 then
            if PersistentBlob.Exists(Rec."Unpack Worksheet Attach.") then begin
                PersistentBlob.Delete(Rec."Unpack Worksheet Attach.");
                Clear(Rec."Unpack Worksheet Attach.");
                UpdateReportStatus();
            end;


    end;

    trigger OnAfterGetRecord()
    begin

        LoadTempTable();


        isVisible := false;

        CheckAqisReq();

        UpdateReportStatus();
        UpdatePercReserved();

        CurrPage.Lines.Page.Update(false);

    end;






    local procedure UpdateReportStatus()
    begin

        If Rec."Unpack Worksheet Attach." > 0 then
            _unpackReportAttached := true else
            _unpackReportAttached := false;

    end;

    local procedure CheckVisible(): Boolean
    var

    begin
        if isVisible then
            exit(true)
        else
            exit(false);

    end;

    local procedure CheckAqisReq()

    begin
        if (rec."Fumigation Req.") or (rec."Inspection Req.") or (rec."IFIP Req.") then
            isAQISRelevant := true
        else
            isAQISRelevant := false;

    end;

    local procedure LoadTempTable()

    begin

        CurrPage.Lines.Page.InitTempTable(Rec);

    end;

    local procedure UpdatePercReserved()

    var
        ContainerContents: Record "TFB ContainerContents" temporary;
    begin

        Clear(_PercReserved);
        Clear(_QtyOnOrder);
        Clear(_QtyReserved);
        Rec.CalcFields("Qty. On Purch. Rcpt");
        If rec.Type = rec.type::PurchaseOrder then
            if rec."Qty. On Purch. Rcpt" > 0 then
                ContainerCU.PopulateReceiptLines(rec, ContainerContents)
            else
                ContainerCU.PopulateOrderOrderLines(Rec, ContainerContents);


        ContainerContents.CalcSums(Quantity, "Qty Sold (Base)");
        _QtyOnOrder := ContainerContents.Quantity;
        _QtyReserved := ContainerContents."Qty Sold (Base)";
        If _QtyOnOrder > 0 then
            _PercReserved := (_QtyReserved / _QtyOnOrder)
        else
            _PercReserved := 0;
    end;

    local procedure AdjustReservedSales()

    var
        PR: Record "Purch. Rcpt. Line";
        LE: Record "Item Ledger Entry";
        SalesCU: CodeUnit "TFB Sales Mgmt";

    begin

        PR.SetRange("Order No.", Rec."Order Reference");
        PR.SetFilter("Quantity (Base)", '>0');

        if PR.FindSet() then
            repeat

                LE.SetRange("Document Type", LE."Document Type"::"Purchase Receipt");
                LE.SetRange("Document No.", PR."Document No.");
                LE.SetRange("Document Line No.", PR."Line No.");

                if LE.FindSet() then
                    repeat
                        SalesCU.AdjustSalesLinePlannedDateByItemRes(LE);
                    until LE.Next() < 1;

            until PR.Next() < 1;

    end;



    local procedure SendWarehouseUpdateEmail(DocNo: Code[20]): Boolean;

    var

        Doc: Record "TFB Container Entry";
        DocLines: Record "TFB ContainerContents" temporary;
        RepSel: Record "Report Selections";
        Purchase: record "Purchase Header";
        Location: record Location;
        ContainerMgmt: CodeUnit "TFB Container Mgmt";
        DocMailing: codeunit "Document-Mailing";
        mgmt: codeunit "TFB Common Library";
        TempBlobHTML: CodeUnit "Temp Blob";
        TempBlob: CodeUnit "Temp Blob";
        TempBlobCOA: CodeUnit "Temp Blob";
        DocumentRef: RecordRef;
        InStreamCOA: Instream;
        OutStreamHTML: OutStream;
        OutStreamReport: OutStream;
        InStreamHTML: InStream;
        InstreamReport: InStream;
        FileName: Text;
        FileNameCOA: Text;

        EmailID: Text;

        Recipients: List of [Text];

        HTMLBuilder: TextBuilder;
        SubjectNameBuilder: TextBuilder;

    begin
        Doc.get(DocNo);
        Purchase.SetRange("No.", Doc."Order Reference");
        Purchase.SetRange("Document Type", Purchase."Document Type"::Order);

        if Purchase.FindFirst() then begin

            Location.Get(Purchase."Location Code");
            HTMLBuilder.Append(mgmt.GetHTMLTemplateActive('Container Details', 'Warehouse Instructions'));

            EmailID := Location."E-Mail";
            Recipients.Add(EmailID);
            SubjectNameBuilder.Append(StrSubstNo('Container Entry %1 from TFB Trading', DocNo));
            ContainerMgmt.GetContainerCoAStream(Doc, TempBlobCOA, FileNameCOA);
            TempBlobHTML.CreateOutStream(OutStreamHTML);

            Rec.SetRecFilter();
            DocumentRef.GetTable(Rec);
            RepSel.SetRange(Usage, RepSel.Usage::"P.Inbound.Shipment.Warehouse");
            RepSel.SetRange("Use for Email Attachment", true);

            FileName := StrSubstNo('Container No. %1 Advice.pdf', Doc."Container No.");
            TempBlob.CreateOutStream(OutStreamReport);
            TempBlobCOA.CreateInStream(InStreamCOA);

            GetNotificationContent(HTMLBuilder, Doc);
            OutStreamHTML.WriteText(HTMLBuilder.ToText());
            TempBlobHTML.CreateInStream(InStreamHTML);
            If Dialog.Confirm('Send Report instead of CoA', false) then begin
                If RepSel.FindFirst() then
                    If REPORT.SaveAs(RepSel."Report ID", '', ReportFormat::Pdf, OutStreamReport, DocumentRef) then begin
                        TempBlob.CreateInStream(InstreamReport);
                        DocMailing.EmailFileAndHtmlFromStream(InstreamReport, FileName, InStreamHTML, EmailID, SubjectNameBuilder.ToText(), false, enum::"Report Selection Usage"::"P.Inbound.Shipment.Warehouse".AsInteger());

                    end;
            end
            else begin

                DocMailing.EmailFileAndHtmlFromStream(InstreamCOA, FileNameCOA, InStreamHTML, EmailID, SubjectNameBuilder.ToText(), false, enum::"Report Selection Usage"::"P.Inbound.Shipment.Warehouse".AsInteger());

            end;
        end;

    end;

    local procedure GetNotificationContent(var HTMLBuilder: TextBuilder; Doc: record "TFB Container Entry"): Boolean

    var


        tdTxt: label '<td valign="top" style="line-height:15px;">%1</td>', comment = '%1=table data html';
        BodyBuilder: TextBuilder;

        ReferenceBuilder: TextBuilder;
        LineBuilder: TextBuilder;
        FieldList: List of [Integer];
        FieldNo: Integer;
        RecordRef: RecordRef;
        FieldRef: FieldRef;
        Content: record "TFB ContainerContents" temporary;


    begin



        HTMLBuilder.Replace('%{ExplanationCaption}', 'Notification type');
        HTMLBuilder.Replace('%{ExplanationValue}', 'Container Shipment Advice');
        HTMLBuilder.Replace('%{DateCaption}', 'Updated On');
        HTMLBuilder.Replace('%{DateValue}', Format(Today(), 0, 4));
        HTMLBuilder.Replace('%{ReferenceCaption}', 'Order References');
        ReferenceBuilder.Append(StrSubstNo('Our order %1', Doc."Order Reference"));

        If Doc."Container No." <> '' then
            ReferenceBuilder.Append(StrSubstNo('<br>Container %1', Doc."Container No."));

        if Doc."Quarantine Reference" <> '' then
            ReferenceBuilder.Append(StrSubstNo('<br>AQIS Ref %1', Doc."Quarantine Reference"));

        HTMLBuilder.Replace('%{ReferenceValue}', ReferenceBuilder.ToText());

        HTMLBuilder.Replace('%{AlertText}', '');

        BodyBuilder.AppendLine('<table class="tfbdata" role="presentation" width="100%" cellspacing="0" cellpadding="10" border="0">');
        BodyBuilder.AppendLine('<thead>');

        BodyBuilder.Append('<th class="tfbdata" style="text-align:left" width="40%">Detail</th>');
        BodyBuilder.Append('<th class="tfbdata" style="text-align:left" width="60%">Current Info</th></thead>');

        FieldList.Add(Doc.FieldNo("Vendor Name"));
        FieldList.Add(Doc.FieldNo("Vendor Reference"));
        FieldList.Add(Doc.FieldNo("Est. Arrival Date"));
        FieldList.Add(Doc.FieldNo("Fumigation Req."));
        FieldList.Add(Doc.FieldNo("Inspection Req."));
        FieldList.Add(Doc.fieldNo("IFIP Req."));
        FieldList.Add(Doc.fieldno("Heat Treat. Req."));

        RecordRef.GetTable(Doc);

        foreach FieldNo in FieldList do begin

            FieldRef := RecordRef.Field(FieldNo);

            If format(FieldRef.Value()) <> '' then begin
                Clear(LineBuilder);
                LineBuilder.AppendLine('<tr>');
                LineBuilder.Append(StrSubstNo(tdTxt, FieldRef.Caption));
                If FieldRef.Type = FieldRef.Type::Date then
                    LineBuilder.Append(StrSubstNo(tdTxt, Format(FieldRef.Value, 0, 4)))
                else
                    LineBuilder.Append(StrSubstNo(tdTxt, Format(FieldRef.Value)));

                LineBuilder.AppendLine('</tr>');
                BodyBuilder.Append(LineBuilder.ToText());
            end;

        end;
        BodyBuilder.AppendLine('</table>');

        BodyBuilder.AppendLine('<table class="tfbdata" role="presentation" width="100%" cellspacing="0" cellpadding="10" border="0">');
        BodyBuilder.AppendLine('<thead>');

        BodyBuilder.Append('<th class="tfbdata" style="text-align:left" width="20%">Code</th>');
        BodyBuilder.Append('<th class="tfbdata" style="text-align:left" width="40%">Description</th>');
        BodyBuilder.Append('<th class="tfbdata" style="text-align:left" width="10%">Qty</th>');
        BodyBuilder.Append('<th class="tfbdata" style="text-align:left" width="10%">Qty Sold</th>');
        BodyBuilder.Append('<th class="tfbdata" style="text-align:left" width="20%">Unit</th></thead>');

        ContainerCU.GetContainerContents(Content, Doc);
        If Content.FindSet() then
            repeat

                clear(LineBuilder);
                LineBuilder.AppendLine('<tr>');
                LineBuilder.Append(StrSubstNo(tdTxt, content."Item Code"));
                LineBuilder.Append(StrSubstNo(tdTxt, content."Item Description"));
                LineBuilder.Append(StrSubstNo(tdTxt, content.Quantity));
                LineBuilder.Append(StrSubstNo(tdTxt, content."Qty Sold (Base)"));
                LineBuilder.Append(StrSubstNo(tdTxt, content.UnitOfMeasure));
                LineBuilder.AppendLine('</tr>');
                BodyBuilder.Append(LineBuilder.ToText());

            until Content.Next() < 1;

        BodyBuilder.AppendLine('</table>');

        HTMLBuilder.Replace('%{EmailContent}', BodyBuilder.ToText());
        Exit(true);

    end;
}