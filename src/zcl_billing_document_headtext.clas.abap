CLASS zcl_billing_document_headtext DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
  INTERFACES if_oo_adt_classrun .
  class-METHODS :
  Billing_HeadText_DATA
   IMPORTING
  VALUE(BillingDocument)           TYPE I_SalesDocumentItem-SalesDocument
        BillingDocumentTextID  TYPE zsd_sales_order_itemtext=>tys_a_sales_order_item_text_ty-long_text_id
  RETURNING VALUE(result12) TYPE string
  RAISING   cx_static_check .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_BILLING_DOCUMENT_HEADTEXT IMPLEMENTATION.


 METHOD Billing_HeadText_DATA.


DATA:
  ls_entity_key    TYPE zsd_billing_document_headtext=>tys_a_billing_document_text_ty,
  ls_business_data TYPE zsd_billing_document_headtext=>tys_a_billing_document_text_ty,
  lo_http_client   TYPE REF TO if_web_http_client,
  lo_resource      TYPE REF TO /iwbep/if_cp_resource_entity,
  lo_client_proxy  TYPE REF TO /iwbep/if_cp_client_proxy,
  lo_request       TYPE REF TO /iwbep/if_cp_request_read,
  lo_response      TYPE REF TO /iwbep/if_cp_response_read.



     TRY.

     DATA : USERNAME TYPE STRING ,
            PASSWORD TYPE STRING .
DATA: lv_url TYPE string .

 lv_url  =   'https://' && cl_abap_context_info=>get_system_url(  ) .

 USERNAME = 'CU_COM_0104'.
 PASSWORD =  'PVmHBeGNeHtkSBnEi2oMTsZsj~upndTtbhEypzGe' .

 lo_http_client = cl_web_http_client_manager=>create_by_http_destination( i_destination = cl_http_destination_provider=>create_by_url( lv_url ) ).
 lo_http_client->get_http_request( )->set_authorization_basic( i_username = USERNAME i_password =  password )  .

lo_client_proxy = /iwbep/cl_cp_factory_remote=>create_v2_remote_proxy(
       EXPORTING
          is_proxy_model_key       = VALUE #( repository_id       = 'DEFAULT'
                                              proxy_model_id      = 'ZSD_BILLING_DOCUMENT_HEADTEXT'
                                              proxy_model_version = '0001' )
         io_http_client             = lo_http_client
         iv_relative_service_root   = '/sap/opu/odata/sap/API_BILLING_DOCUMENT_SRV' ).

     ASSERT lo_http_client IS BOUND.

" Set entity key
ls_entity_key = VALUE #(
          billing_document  = billingdocument
          language          = 'EN'
          long_text_id      = billingdocumenttextid ).

" Navigate to the resource
lo_resource = lo_client_proxy->create_resource_for_entity_set( 'A_BILLING_DOCUMENT_TEXT' )->navigate_with_key( ls_entity_key ).

" Execute the request and retrieve the business data
lo_response = lo_resource->create_request_for_read( )->execute( ).
lo_response->get_business_data( IMPORTING es_business_data = ls_business_data ).
result12 = ls_business_data-long_text.
 DATA WA_zso_itemtext_dat TYPE zso_itemtext_dat .
 WA_zso_itemtext_dat-salesorder           = ls_business_data-billing_document.
 WA_zso_itemtext_dat-so_item_longtext     = ls_business_data-long_text.
 WA_zso_itemtext_dat-so_item_long_text_id = ls_business_data-long_text_id.
 MODIFY zso_itemtext_dat FROM @WA_zso_itemtext_dat .

  CATCH /iwbep/cx_cp_remote INTO DATA(lx_remote).
" Handle remote Exception
" It contains details about the problems of your http(s) connection

CATCH /iwbep/cx_gateway INTO DATA(lx_gateway).
" Handle Exception

CATCH cx_web_http_client_error INTO DATA(lx_web_http_client_error).
" Handle Exception
 RAISE SHORTDUMP lx_web_http_client_error.


ENDTRY.

 ENDMETHOD.


  METHOD if_oo_adt_classrun~main.

 DATA(RES) = zcl_billing_document_headtext=>Billing_HeadText_DATA( BillingDocument = 'U123100016' BillingDocumentTextID = 'TX15' )  .

  ENDMETHOD.
ENDCLASS.
