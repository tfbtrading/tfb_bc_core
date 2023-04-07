page 50113 "TFB Vend. Ledg. Appl. FactBox"
{

    Caption = 'Invoices Applied FactBox';
    PageType = ListPart;
    SourceTable = "Vendor Ledger Entry";
    SourceTableView = sorting("External Document No.") where("Remaining Amount" = filter('<>0'));

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("External Document No."; Rec."External Document No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the external document no. supplied by the vendor';
                }
                field("Remaining Amount"; Rec."Remaining Amount")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the amount remaining to be paid on the invoice';
                }

                field(_IDAFilename; _DownloadSymbol)
                {
                    ApplicationArea = All;
                    Width = 10;
                    Caption = 'Incoming Doc. File';
                    ToolTip = 'Specifies filename';
                    DrillDown = true;

                    trigger OnDrillDown()

                    begin
                        if _DownloadSymbol <> '' then
                            downloadIncomingDoc();
                    end;
                }
            }


        }




    }


    actions
    {
        area(Processing)
        {

            action("Item Ledger Entries")
            {
                ApplicationArea = All;
                Image = LedgerEntries;
                Caption = 'Item Ledger Entries';
                ToolTip = 'View Item Ledger Entries';
                Scope = Repeater;
                trigger onAction()

                begin
                    if not rec.IsEmpty then
                        showItemLedgerEntries();
                end;
            }

            action("Posted Invoice")
            {
                ApplicationArea = All;
                Image = Invoice;
                Caption = 'Purchase Invoice';
                ToolTip = 'View Purchase Invoice';
                Scope = Repeater;


                trigger onAction()

                begin
                    if not rec.IsEmpty then
                        Rec.ShowDoc();
                end;
            }
            action(ViewPDF)
            {
                ApplicationArea = All;
                Caption = 'View';
                scope = Repeater;
                Image = View;
                Enabled = true;
                tooltip = 'Preview';

                trigger OnAction()
                begin
                    viewAttachment();
                end;
            }
        }
    }


    var
        _IDA: Record "Incoming Document Attachment";
        _DownloadSymbol: Text;

    trigger OnAfterGetRecord()

    var
        ID: Record "Incoming Document";
        IDA: Record "Incoming Document Attachment";
        RecRef: RecordRef;

    begin
        //Ensure variables are clean
        _DownloadSymbol := '';
        Clear(_IDA);
        RecRef.GetTable(Rec);
        if ID.FindByDocumentNoAndPostingDate(RecRef, ID) then
            if ID.GetMainAttachment(IDA) then begin
                RecRef.GetTable(IDA);
                if IDA.GetFullName() <> '' then
                    _DownloadSymbol := '📥'
                else
                    _DownloadSymbol := '🚫';
                _IDA := IDA;

            end;

    end;

    local procedure viewAttachment()

    begin
        if not _IDA.IsEmpty then
            _IDA.ViewAttachment();
    end;

    local procedure downloadIncomingDoc()

    var

        TempBlob: CodeUnit "Temp Blob";
        RecRef: RecordRef;
        FileName: Text;
        InStream: InStream;

    begin
        if not _IDA.IsEmpty() then begin
            RecRef.GetTable(_IDA);
            TempBlob.FromRecordRef(RecRef, _IDA.FieldNo(Content));
            FileName := _IDA.GetFullName();
            if TempBlob.HasValue() then begin
                TempBlob.CreateInStream(InStream);
                if not DownloadFromStream(InStream, 'Title', 'ToFolder', 'Filter', FileName) then
                    Error('File Not Downloaded');
            end;
        end;
    end;

    local procedure showItemLedgerEntries()

    var
        PL: Record "Purch. Inv. Line";
        TempItemLedger: Record "Item Ledger Entry" temporary;
        ItemLedger: Record "Item Ledger Entry";
        ItemLedgerPage: Page "Item Ledger Entries";


    begin

        PL.SetRange("Document No.", Rec."Document No.");
        PL.SetFilter(Quantity, '<>0');
        PL.SetRange(Type, PL.Type::Item);

        Clear(TempItemLedger);
        if PL.Findset(false) then
            repeat

                PL.GetItemLedgEntries(TempItemLedger, false); //Set false as we want to aggregate and not reset for each line item

            until PL.Next() < 1;

        ItemLedger.Copy(TempItemLedger, false);
        ItemLedgerPage.SetRecord(ItemLedger);
        ItemLedgerPage.Run();

    end;

}
