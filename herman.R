library(RSelenium)
library(rvest)
library(tidyverse)
library(httr)


system('docker run -d -p 4445:4444 selenium/standalone-chrome')
Sys.sleep(5)
selenium_server_name = "localhost"
shopee_user = "hermandr@gmail.com"
shopee_password = "Nawamrad1"

remDr <-  RSelenium::remoteDriver(
  remoteServerAddr = selenium_server_name,
  port = 4445L,
  browserName = "chrome"
)

url="https://seller.shopee.co.id"
remDr$open()
remDr$navigate(url)
remDr$getCurrentUrl()
remDr$maxWindowSize()
Sys.sleep(5)
remDr$screenshot(file="seller-shopee-without-login.png")

webElem <- remDr$findElement(
  using = "css",
  '#app > div.app-container > div > div > div > div > div.login.col-6 > div > div > div > form > div:nth-child(1) > div > div > div > div > input'
)

webElem$sendKeysToElement(list(shopee_user,key="tab",
                               shopee_password,
                               key="enter"))

remDr$getCurrentUrl()


Sys.sleep(5)

remDr$maxWindowSize()
remDr$screenshot(file="seller-shopee-after_login.png")

cookies = remDr$getAllCookies()
cookies %>%  as.matrix %>%
  as_tibble(.name_repair = "unique") %>% rename(V1=1) %>% 
  mutate( domain = map_chr(V1,"domain"),
          httpOnly = map_chr(V1,"httpOnly"),
          expiry = map(V1,"expiry"),
          #exp_length = map_int(expiry,length),
          name = map_chr(V1,"name"),
          path = map_chr(V1,"path"),
          secure = map_chr(V1,"secure"),
          value = map_chr(V1,"value")
  ) -> after_cookies

url_string <- remDr$executeScript(
  'var performance = window.performance || window.mozPerformance || window.msPerformance || window.webkitPerformance || {}; var network = performance.getEntries() || {}; return network;'
) %>%
  as.matrix %>%
  as_tibble(.name_repair = "unique") %>% 
  rename(V1=1) %>% 
  mutate(name = map_chr(V1,"name")) %>% 
  select(name) %>%
  filter_all(all_vars(grepl('https://seller.shopee.co.id/webchat/api/v1.2/mini/login', .))) %>%
  as.character()

gsub('^.|.$', '', after_cookies$value)
ck <- after_cookies$value
names(ck) <- after_cookies$name

POST(url = url_string,
     add_headers(
       `X-Requested-With` = "XMLHttpRequest"
       
     ),
     set_cookies(SPC_CDS=ck[['SPC_CDS']],
                 SPC_SC_TK=ck[['SPC_SC_TK']],
                 SPC_EC=gsub('^.|.$', '', ck[['SPC_EC']]),
                 SPC_F=ck[['SPC_F']],
                 SPC_STK=as.character(ck[['SPC_STK']]),
                 SPC_SC_UD=ck[['SPC_SC_UD']],
                 SPC_WST=as.character(ck[['SPC_EC']]),
                 SPC_U=ck[['SPC_U']],
                 SC_DFP=ck[['SC_DFP']]),
     verbose()
) -> res

class(content(res))
res_cred_df <- content(res)
res_cred_df %>%
token = res$tok
