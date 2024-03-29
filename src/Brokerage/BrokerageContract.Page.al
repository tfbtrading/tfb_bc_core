page 50240 "TFB Brokerage Contract"
{
    PageType = Document;

    SourceTable = "TFB Brokerage Contract";
    DataCaptionFields = "No.", "Vendor No.", "Customer Name";
    Caption = 'Brokerage Contract';
    ApplicationArea = All;
    UsageCategory = Documents;

    layout
    {

        area(FactBoxes)
        {

            systempart(Links; Links)
            {
                ApplicationArea = RecordLinks;
            }
            systempart(Notes; Notes)
            {
                ApplicationArea = Notes;
            }
        }
        area(Content)
        {
            group("General")
            {

                field("No."; Rec."No.")
                {
                    ToolTip = 'Specifies no. of brokerage contract';
                }
                field("Customer No."; Rec."Customer No.")
                {
                    Importance = Additional;
                    ToolTip = 'Specifies customer no.';
                    Lookup = true;
                    LookupPageId = "Customer Card";

                }
                field("Customer Name"; Rec."Customer Name")
                {
                    Importance = Promoted;
                    ToolTip = 'Specifies customer name';
                }

                field("Sell-to Contact No."; Rec."Sell-to Contact No.")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Contact No.';
                    Editable = Rec."Customer No." <> '';
                    Importance = Additional;
                    ToolTip = 'Specifies the number of the contact person that the sales document will be sent to.';

                    trigger OnValidate()
                    begin
                        if Rec.GetFilter("Sell-to Contact No.") = xRec."Sell-to Contact No." then
                            if Rec."Sell-to Contact No." <> xRec."Sell-to Contact No." then
                                Rec.SetRange("Sell-to Contact No.");
                    end;
                }
                field("Sell-to Contact"; Rec."Sell-to Contact")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Contact';
                    Editable = Rec."Customer No." <> '';
                    ToolTip = 'Specifies the name of the person to contact at the customer.';
                }
                field("Vendor No."; Rec."Vendor No.")
                {
                    Importance = Additional;
                    ToolTip = 'Specifies vendor no.';
                    Lookup = true;
                    LookupPageId = "Vendor Card";


                }
                field("Vendor Name"; Rec."Vendor Name")
                {
                    Importance = Promoted;
                    ToolTip = 'Specifies vendor name';
                }
                field("Buy-from Contact No."; Rec."Buy-from Contact No.")
                {
                    ApplicationArea = Suite;
                    Caption = 'Vendor Contact No.';
                    Importance = Additional;
                    ToolTip = 'Specifies the number of contact person of the vendor''s buy-from.';
                }
                field("Buy-from Contact"; Rec."Buy-from Contact")
                {
                    ApplicationArea = Suite;
                    Caption = 'Vendor Contact';
                    Editable = Rec."Vendor No." <> '';
                    ToolTip = 'Specifies the name of the person to contact about an order from this vendor.';
                }
                field("External Reference No."; Rec."External Reference No.")
                {
                    Importance = Promoted;
                    ToolTip = 'Specifies external ref. no';
                }
                field("Crop Year"; Rec."Crop Year")
                {
                    ToolTip = 'Specifies crop year';
                }
                field("Container Route"; Rec."Container Route")
                {
                    ToolTip = 'Specifies container route';

                }
                field("Commission Type"; Rec."Commission Type")
                {
                    Importance = Additional;
                    ToolTip = 'Specifies commission type';

                }
                group(FixedRate)
                {
                    ShowCaption = false;
                    Visible = Rec."Commission Type" = Rec."Commission Type"::"$ per MT";

                    field("Fixed Rate"; Rec."Fixed Rate")
                    {
                        Importance = Additional;
                        ToolTip = 'Specifies fixed rate for contract';


                    }
                }
                group(PercRate)
                {
                    ShowCaption = false;
                    Visible = Rec."Commission Type" = Rec."Commission Type"::"% of Value";

                    field("Percentage"; Rec."Percentage")
                    {
                        Importance = Additional;
                        ToolTip = 'Specifies percentage commission for contract';

                        trigger OnValidate()

                        begin
                            CurrPage.ContractLines.Page.Update();
                        end;



                    }

                }
                field("Date Signed"; Rec."Date Signed")
                {
                    ToolTip = 'Specifies date signed for contract';
                }
                field("Payment Terms Code"; Rec."Payment Terms Code")
                {
                    Importance = Additional;
                    ToolTip = 'Specifies payment terms for contract. Used to calculate defaulte due date';

                }
                field("Currency"; Rec."Currency")
                {
                    Importance = Additional;
                    ToolTip = 'Specifies currency for contract';
                }
                field("Vendor Price Unit"; Rec."Vendor Price Unit")
                {
                    ToolTip = 'Specifies vendor price unit';

                }

                field("Shipping Method Code"; Rec."Shipping Method Code")
                {
                    Importance = Promoted;
                    ToolTip = 'Specifies shipping method code';

                    trigger OnValidate()

                    begin
                        UpdateFreightVisibility();
                    end;
                }

                group(ShipmentMethodDetails)
                {
                    ShowCaption = false;
                    Visible = FreightExtra;

                    field("Est. Freight Per MT"; Rec."Est. Freight Per MT")
                    {
                        ToolTip = 'Specifies est. freight per metric tonne';
                    }


                }



                field("Status"; Rec."Status")
                {
                    Importance = Promoted;
                    ToolTip = 'Specifies status of contract';
                    Style = Attention;
                    StyleExpr = Rec.Status = Rec.status::Draft;
                }


                field("Contract Attach."; IsContractAttached())
                {
                    AssistEdit = true;
                    Caption = 'Contract Attached';
                    Editable = false;
                    ToolTip = 'Specifies if contract is attached';

                    trigger OnAssistEdit()

                    begin
                        if _contractAttached then
                            if Dialog.Confirm('Just delete attached file?') then
                                RemoveFile()
                            else
                                AttachFile()
                        else
                            AttachFile();
                    end;



                }


                field("No. of Shipments"; Rec."No. of Shipments")
                {
                    DrillDown = true;
                    DrillDownPageId = "TFB Brokerage Shipment List";
                    ToolTip = 'Specifies number of shipments for contract';
                }




            }

            part(ContractLines; "TFB Brokerage Contract Subform")
            {
                Caption = 'Lines';
                SubPageLink = "Document No." = field("No.");
                UpdatePropagation = Both;
                Visible = true;
            }


        }



    }
    actions
    {
        area(Processing)
        {
            action(Upload)
            {
                Caption = 'Upload contract';
                ToolTip = 'Upload the contract file if it exists';

                Image = ExportAttachment;
                Enabled = not _contractAttached;

                trigger OnAction()
                begin
                    AttachFile();
                end;
            }
            action(Delete)
            {
                Caption = 'Delete contract';
                ToolTip = 'Delete the contract file if it exists';

                Image = ExportAttachment;
                Enabled = _contractAttached;

                trigger OnAction()
                begin
                    RemoveFile();
                end;
            }
            action(Download)
            {
                Caption = 'Download contract';
                ToolTip = 'Download the contract file if it exists';

                Image = ExportAttachment;
                Enabled = _contractAttached;

                trigger OnAction()
                begin
                    DownloadFile();
                end;
            }
        }
        area(Promoted)
        {
            group(Category_Home)
            {
                Caption = 'Home';
                actionref(UploadRef; Upload)
                {

                }
                actionref(DownloadRef; Download)
                {

                }
                actionref(DeleteRef; Delete)
                {

                }

            }
        }
    }

    var
        FreightExtra: Boolean;
        _contractAttached: Boolean;


    trigger OnAfterGetRecord()

    begin
        UpdateFreightVisibility();
        IsContractAttached();
    end;

    /// <summary> 
    /// Determines whether details brokerage price includes or excludes freight
    /// </summary>
    local procedure UpdateFreightVisibility()

    var
        ShipmentMethod: Record "Shipment Method";

    begin
        if ShipmentMethod.Get(Rec."Shipping Method Code") then
            FreightExtra := ShipmentMethod."TFB Freight Exclusive";

    end;

    /// <summary> 
    /// Allows a brokerage contract pdf to be uploaded
    /// </summary>
    local procedure AttachFile()

    var

        TempBlob: Codeunit "Temp Blob";
        PersistBlobCU: CodeUnit "Persistent Blob";
        FileManagement: CodeUnit "File Management";

        ExtFilterTxt: Label 'pdf';
        FileFilterTxt: Label 'All files (*.pdf)|*.pdf';
        FileDialogTxt: Label 'Select Contract File to Upload';

        IStream: InStream;

        BlobRef: BigInteger;


    begin






        FileManagement.BLOBImportWithFilter(TempBlob, FileDialogTxt, '', FileFilterTxt, ExtFilterTxt);


        BlobRef := PersistBlobCU.Create();
        TempBlob.CreateInStream(IStream);

        if PersistBlobCU.CopyFromInStream(BlobRef, IStream) then
            Rec."Contract Attach." := BlobRef;

        rec.Modify();


    end;


    /// <summary> 
    /// Download contract attachment file
    /// </summary>
    local procedure DownloadFile()

    var

        PersistentBlob: Codeunit "Persistent Blob";
        TempBlob: CodeUnit "Temp Blob";
        FileNameBuilder: TextBuilder;
        FileName: Text;
        InStream: InStream;
        OutStream: OutStream;

    begin


        if Rec."Contract Attach." > 0 then
            if PersistentBlob.Exists(Rec."Contract Attach.") then begin
                FileNameBuilder.Append('Contract_');
                FileNameBuilder.Append(Rec."No.");
                FileNameBuilder.Append('.pdf');
                FileName := FileNameBuilder.ToText();
                TempBlob.CreateInStream(InStream);
                TempBlob.CreateOutStream(OutStream);
                PersistentBlob.CopyToOutStream(Rec."Contract Attach.", OutStream);
                CopyStream(OutStream, InStream);
                if not DownloadFromStream(InStream, 'Title', 'ToFolder', 'Filter', FileName) then
                    Error('File Not Downloaded');
            end;
    end;

    /// <summary> 
    /// Remove contract attachment blob
    /// </summary>
    local procedure RemoveFile()
    var
        PersistentBlob: Codeunit "Persistent Blob";
    begin

        if Rec."Contract Attach." > 0 then
            if PersistentBlob.Exists(Rec."Contract Attach.") then begin
                Clear(Rec."Contract Attach.");
                PersistentBlob.Delete(Rec."Contract Attach.");
            end;

    end;

    /// <summary> 
    /// Checks if a contract is attached based on the contract attachment number
    /// </summary>
    /// <returns>Return variable "Boolean".</returns>
    local procedure IsContractAttached(): Boolean

    var
        PersistentBlob: Codeunit "Persistent Blob";

    begin
        _contractAttached := PersistentBlob.Exists(Rec."Contract Attach.");
        exit(_contractAttached);

    end;


}

