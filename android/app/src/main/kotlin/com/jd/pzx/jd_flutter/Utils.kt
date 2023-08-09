package com.jd.pzx.jd_flutter

import android.app.Activity
import android.content.Context
import android.content.Intent
import android.content.res.Configuration
import android.graphics.Bitmap
import android.net.Uri
import android.os.Build
import android.util.Base64
import android.util.DisplayMetrics
import android.util.Log
import android.view.View
import androidx.core.content.FileProvider
import java.io.ByteArrayOutputStream
import java.io.File
import java.math.BigDecimal
import java.math.RoundingMode
import java.text.DecimalFormat
import java.text.SimpleDateFormat
import java.util.*

const val CHANNEL_ANDROID_SEND = "com.jd.pzx.jd_flutter_android_send"
const val CHANNEL_FLUTTER_SEND = "com.jd.pzx.jd_flutter_flutter_send"
const val FACE_VERIFY_SUCCESS = 1
const val FACE_VERIFY_FAIL_NOT_LIVE = 2
const val FACE_VERIFY_FAIL_NOT_ME = 3
const val FACE_VERIFY_FAIL_ERROR = 4
val fileIMEI_Simple = mapOf(
    ".3gp" to "video/3gpp",
    ".apk" to "application/vnd.android.package-archive",
    ".asf" to "video/x-ms-asf",
    ".avi" to "video/x-msvideo",
    ".bin" to "application/octet-stream",
    ".bmp" to "image/bmp",
    ".c" to "text/plain",
    ".chm" to "application/x-chm",
    ".class" to "application/octet-stream",
    ".conf" to "text/plain",
    ".cpp" to "text/plain",
    ".doc" to "application/msword",
    ".docx" to "application/msword",
    ".exe" to "application/octet-stream",
    ".gif" to "image/gif",
    ".gtar" to "application/x-gtar",
    ".gz" to "application/x-gzip",
    ".h" to "text/plain",
    ".htm" to "text/html",
    ".html" to "text/html",
    ".jar" to "application/java-archive",
    ".java" to "text/plain",
    ".jpeg" to "image/jpeg",
    ".jpg" to "image/jpeg",
    ".js" to "application/x-javascript",
    ".log" to "text/plain",
    ".m3u" to "audio/x-mpegurl",
    ".m4a" to "audio/mp4a-latm",
    ".m4b" to "audio/mp4a-latm",
    ".m4p" to "audio/mp4a-latm",
    ".m4u" to "video/vnd.mpegurl",
    ".m4v" to "video/x-m4v",
    ".mov" to "video/quicktime",
    ".mp2" to "audio/x-mpeg",
    ".mp3" to "audio/x-mpeg",
    ".mp4" to "video/mp4",
    ".mpc" to "application/vnd.mpohun.certificate",
    ".mpe" to "video/mpeg",
    ".mpeg" to "video/mpeg",
    ".mpg" to "video/mpeg",
    ".mpg4" to "video/mp4",
    ".mpga" to "audio/mpeg",
    ".msg" to "application/vnd.ms-outlook",
    ".ogg" to "audio/ogg",
    ".pdf" to "application/pdf",
    ".png" to "image/png",
    ".pps" to "application/vnd.ms-powerpoint",
    ".ppt" to "application/vnd.ms-powerpoint",
    ".pptx" to "application/vnd.ms-powerpoint",
    ".prop" to "text/plain",
    ".rar" to "application/x-rar-compressed",
    ".rc" to "text/plain",
    ".rmvb" to "audio/x-pn-realaudio",
    ".rtf" to "application/rtf",
    ".sh" to "text/plain",
    ".tar" to "application/x-tar",
    ".tgz" to "application/x-compressed",
    ".txt" to "text/plain",
    ".wav" to "audio/x-wav",
    ".wma" to "audio/x-ms-wma",
    ".wmv" to "audio/x-ms-wmv",
    ".wps" to "application/vnd.ms-works",
    ".xml" to "text/plain",
    ".xls" to "application/vnd.ms-excel",
    ".xlsx" to "application/vnd.ms-excel",
    ".z" to "application/x-compress",
    ".zip" to "application/zip",
    "" to "*/*"
)

val fileIMEI_all = mapOf(
    "3gp" to "video/3gpp",
    "aab" to "application/x-authoware-bin",
    "aam" to "application/x-authoware-map",
    "aas" to "application/x-authoware-seg",
    "ai" to "application/postscript",
    "aif" to "audio/x-aiff",
    "aifc" to "audio/x-aiff",
    "aiff" to "audio/x-aiff",
    "als" to "audio/X-Alpha5",
    "amc" to "application/x-mpeg",
    "ani" to "application/octet-stream",
    "apk" to "application/vnd.android.package-archive",
    "asc" to "text/plain",
    "asd" to "application/astound",
    "asf" to "video/x-ms-asf",
    "asn" to "application/astound",
    "asp" to "application/x-asap",
    "asx" to "video/x-ms-asf",
    "au" to "audio/basic",
    "avb" to "application/octet-stream",
    "avi" to "video/x-msvideo",
    "awb" to "audio/amr-wb",
    "bcpio" to "application/x-bcpio",
    "bin" to "application/octet-stream",
    "bld" to "application/bld",
    "bld2" to "application/bld2",
    "bmp" to "image/bmp",
    "bpk" to "application/octet-stream",
    "bz2" to "application/x-bzip2",
    "cal" to "image/x-cals",
    "ccn" to "application/x-cnc",
    "cco" to "application/x-cocoa",
    "cdf" to "application/x-netcdf",
    "cgi" to "magnus-internal/cgi",
    "chat" to "application/x-chat",
    "class" to "application/octet-stream",
    "clp" to "application/x-msclip",
    "cmx" to "application/x-cmx",
    "co" to "application/x-cult3d-object",
    "cod" to "image/cis-cod",
    "cpio" to "application/x-cpio",
    "cpt" to "application/mac-compactpro",
    "crd" to "application/x-mscardfile",
    "csh" to "application/x-csh",
    "csm" to "chemical/x-csml",
    "csml" to "chemical/x-csml",
    "css" to "text/css",
    "cur" to "application/octet-stream",
    "dcm" to "x-lml/x-evm",
    "dcr" to "application/x-director",
    "dcx" to "image/x-dcx",
    "dhtml" to "text/html",
    "dir" to "application/x-director",
    "dll" to "application/octet-stream",
    "dmg" to "application/octet-stream",
    "dms" to "application/octet-stream",
    "doc" to "application/msword",
    "dot" to "application/x-dot",
    "dvi" to "application/x-dvi",
    "dwf" to "drawing/x-dwf",
    "dwg" to "application/x-autocad",
    "dxf" to "application/x-autocad",
    "dxr" to "application/x-director",
    "ebk" to "application/x-expandedbook",
    "emb" to "chemical/x-embl-dl-nucleotide",
    "embl" to "chemical/x-embl-dl-nucleotide",
    "eps" to "application/postscript",
    "eri" to "image/x-eri",
    "es" to "audio/echospeech",
    "esl" to "audio/echospeech",
    "etc" to "application/x-earthtime",
    "etx" to "text/x-setext",
    "evm" to "x-lml/x-evm",
    "evy" to "application/x-envoy",
    "exe" to "application/octet-stream",
    "fh4" to "image/x-freehand",
    "fh5" to "image/x-freehand",
    "fhc" to "image/x-freehand",
    "fif" to "image/fif",
    "fm" to "application/x-maker",
    "fpx" to "image/x-fpx",
    "fvi" to "video/isivideo",
    "gau" to "chemical/x-gaussian-input",
    "gca" to "application/x-gca-compressed",
    "gdb" to "x-lml/x-gdb",
    "gif" to "image/gif",
    "gps" to "application/x-gps",
    "gtar" to "application/x-gtar",
    "gz" to "application/x-gzip",
    "hdf" to "application/x-hdf",
    "hdm" to "text/x-hdml",
    "hdml" to "text/x-hdml",
    "hlp" to "application/winhlp",
    "hqx" to "application/mac-binhex40",
    "htm" to "text/html",
    "html" to "text/html",
    "hts" to "text/html",
    "ice" to "x-conference/x-cooltalk",
    "ico" to "application/octet-stream",
    "ief" to "image/ief",
    "ifm" to "image/gif",
    "ifs" to "image/ifs",
    "imy" to "audio/melody",
    "ins" to "application/x-NET-Install",
    "ips" to "application/x-ipscript",
    "ipx" to "application/x-ipix",
    "it" to "audio/x-mod",
    "itz" to "audio/x-mod",
    "ivr" to "i-world/i-vrml",
    "j2k" to "image/j2k",
    "jad" to "text/vnd.sun.j2me.app-descriptor",
    "jam" to "application/x-jam",
    "jar" to "application/java-archive",
    "jnlp" to "application/x-java-jnlp-file",
    "jpe" to "image/jpeg",
    "jpeg" to "image/jpeg",
    "jpg" to "image/jpeg",
    "jpz" to "image/jpeg",
    "js" to "application/x-javascript",
    "jwc" to "application/jwc",
    "kjx" to "application/x-kjx",
    "lak" to "x-lml/x-lak",
    "latex" to "application/x-latex",
    "lcc" to "application/fastman",
    "lcl" to "application/x-digitalloca",
    "lcr" to "application/x-digitalloca",
    "lgh" to "application/lgh",
    "lha" to "application/octet-stream",
    "lml" to "x-lml/x-lml",
    "lmlpack" to "x-lml/x-lmlpack",
    "lsf" to "video/x-ms-asf",
    "lsx" to "video/x-ms-asf",
    "lzh" to "application/x-lzh",
    "m13" to "application/x-msmediaview",
    "m14" to "application/x-msmediaview",
    "m15" to "audio/x-mod",
    "m3u" to "audio/x-mpegurl",
    "m3url" to "audio/x-mpegurl",
    "ma1" to "audio/ma1",
    "ma2" to "audio/ma2",
    "ma3" to "audio/ma3",
    "ma5" to "audio/ma5",
    "man" to "application/x-troff-man",
    "map" to "magnus-internal/imagemap",
    "mbd" to "application/mbedlet",
    "mct" to "application/x-mascot",
    "mdb" to "application/x-msaccess",
    "mdz" to "audio/x-mod",
    "me" to "application/x-troff-me",
    "mel" to "text/x-vmel",
    "mi" to "application/x-mif",
    "mid" to "audio/midi",
    "midi" to "audio/midi",
    "mif" to "application/x-mif",
    "mil" to "image/x-cals",
    "mio" to "audio/x-mio",
    "mmf" to "application/x-skt-lbs",
    "mng" to "video/x-mng",
    "mny" to "application/x-msmoney",
    "moc" to "application/x-mocha",
    "mocha" to "application/x-mocha",
    "mod" to "audio/x-mod",
    "mof" to "application/x-yumekara",
    "mol" to "chemical/x-mdl-molfile",
    "mop" to "chemical/x-mopac-input",
    "mov" to "video/quicktime",
    "movie" to "video/x-sgi-movie",
    "mp2" to "audio/x-mpeg",
    "mp3" to "audio/x-mpeg",
    "mp4" to "video/mp4",
    "mpc" to "application/vnd.mpohun.certificate",
    "mpe" to "video/mpeg",
    "mpeg" to "video/mpeg",
    "mpg" to "video/mpeg",
    "mpg4" to "video/mp4",
    "mpga" to "audio/mpeg",
    "mpn" to "application/vnd.mophun.application",
    "mpp" to "application/vnd.ms-project",
    "mps" to "application/x-mapserver",
    "mrl" to "text/x-mrml",
    "mrm" to "application/x-mrm",
    "ms" to "application/x-troff-ms",
    "mts" to "application/metastream",
    "mtx" to "application/metastream",
    "mtz" to "application/metastream",
    "mzv" to "application/metastream",
    "nar" to "application/zip",
    "nbmp" to "image/nbmp",
    "nc" to "application/x-netcdf",
    "ndb" to "x-lml/x-ndb",
    "ndwn" to "application/ndwn",
    "nif" to "application/x-nif",
    "nmz" to "application/x-scream",
    "nokia-op-logo" to "image/vnd.nok-oplogo-color",
    "npx" to "application/x-netfpx",
    "nsnd" to "audio/nsnd",
    "nva" to "application/x-neva1",
    "oda" to "application/oda",
    "oom" to "application/x-AtlasMate-Plugin",
    "pac" to "audio/x-pac",
    "pae" to "audio/x-epac",
    "pan" to "application/x-pan",
    "pbm" to "image/x-portable-bitmap",
    "pcx" to "image/x-pcx",
    "pda" to "image/x-pda",
    "pdb" to "chemical/x-pdb",
    "pdf" to "application/pdf",
    "pfr" to "application/font-tdpfr",
    "pgm" to "image/x-portable-graymap",
    "pict" to "image/x-pict",
    "pm" to "application/x-perl",
    "pmd" to "application/x-pmd",
    "png" to "image/png",
    "pnm" to "image/x-portable-anymap",
    "pnz" to "image/png",
    "pot" to "application/vnd.ms-powerpoint",
    "ppm" to "image/x-portable-pixmap",
    "pps" to "application/vnd.ms-powerpoint",
    "ppt" to "application/vnd.ms-powerpoint",
    "pqf" to "application/x-cprplayer",
    "pqi" to "application/cprplayer",
    "prc" to "application/x-prc",
    "proxy" to "application/x-ns-proxy-autoconfig",
    "ps" to "application/postscript",
    "ptlk" to "application/listenup",
    "pub" to "application/x-mspublisher",
    "pvx" to "video/x-pv-pvx",
    "qcp" to "audio/vnd.qcelp",
    "qt" to "video/quicktime",
    "qti" to "image/x-quicktime",
    "qtif" to "image/x-quicktime",
    "r3t" to "text/vnd.rn-realtext3d",
    "ra" to "audio/x-pn-realaudio",
    "ram" to "audio/x-pn-realaudio",
    "rar" to "application/x-rar-compressed",
    "ras" to "image/x-cmu-raster",
    "rdf" to "application/rdf+xml",
    "rf" to "image/vnd.rn-realflash",
    "rgb" to "image/x-rgb",
    "rlf" to "application/x-richlink",
    "rm" to "audio/x-pn-realaudio",
    "rmf" to "audio/x-rmf",
    "rmm" to "audio/x-pn-realaudio",
    "rmvb" to "audio/x-pn-realaudio",
    "rnx" to "application/vnd.rn-realplayer",
    "roff" to "application/x-troff",
    "rp" to "image/vnd.rn-realpix",
    "rpm" to "audio/x-pn-realaudio-plugin",
    "rt" to "text/vnd.rn-realtext",
    "rte" to "x-lml/x-gps",
    "rtf" to "application/rtf",
    "rtg" to "application/metastream",
    "rtx" to "text/richtext",
    "rv" to "video/vnd.rn-realvideo",
    "rwc" to "application/x-rogerwilco",
    "s3m" to "audio/x-mod",
    "s3z" to "audio/x-mod",
    "sca" to "application/x-supercard",
    "scd" to "application/x-msschedule",
    "sdf" to "application/e-score",
    "sea" to "application/x-stuffit",
    "sgm" to "text/x-sgml",
    "sgml" to "text/x-sgml",
    "sh" to "application/x-sh",
    "shar" to "application/x-shar",
    "shtml" to "magnus-internal/parsed-html",
    "shw" to "application/presentations",
    "si6" to "image/si6",
    "si7" to "image/vnd.stiwap.sis",
    "si9" to "image/vnd.lgtwap.sis",
    "sis" to "application/vnd.symbian.install",
    "sit" to "application/x-stuffit",
    "skd" to "application/x-Koan",
    "skm" to "application/x-Koan",
    "skp" to "application/x-Koan",
    "skt" to "application/x-Koan",
    "slc" to "application/x-salsa",
    "smd" to "audio/x-smd",
    "smi" to "application/smil",
    "smil" to "application/smil",
    "smp" to "application/studiom",
    "smz" to "audio/x-smd",
    "snd" to "audio/basic",
    "spc" to "text/x-speech",
    "spl" to "application/futuresplash",
    "spr" to "application/x-sprite",
    "sprite" to "application/x-sprite",
    "spt" to "application/x-spt",
    "src" to "application/x-wais-source",
    "stk" to "application/hyperstudio",
    "stm" to "audio/x-mod",
    "sv4cpio" to "application/x-sv4cpio",
    "sv4crc" to "application/x-sv4crc",
    "svf" to "image/vnd",
    "svg" to "image/svg-xml",
    "svh" to "image/svh",
    "svr" to "x-world/x-svr",
    "swf" to "application/x-shockwave-flash",
    "swfl" to "application/x-shockwave-flash",
    "t" to "application/x-troff",
    "tad" to "application/octet-stream",
    "talk" to "text/x-speech",
    "tar" to "application/x-tar",
    "taz" to "application/x-tar",
    "tbp" to "application/x-timbuktu",
    "tbt" to "application/x-timbuktu",
    "tcl" to "application/x-tcl",
    "tex" to "application/x-tex",
    "texi" to "application/x-texinfo",
    "texinfo" to "application/x-texinfo",
    "tgz" to "application/x-tar",
    "thm" to "application/vnd.eri.thm",
    "tif" to "image/tiff",
    "tiff" to "image/tiff",
    "tki" to "application/x-tkined",
    "tkined" to "application/x-tkined",
    "toc" to "application/toc",
    "toy" to "image/toy",
    "tr" to "application/x-troff",
    "trk" to "x-lml/x-gps",
    "trm" to "application/x-msterminal",
    "tsi" to "audio/tsplayer",
    "tsp" to "application/dsptype",
    "tsv" to "text/tab-separated-values",
    "ttf" to "application/octet-stream",
    "ttz" to "application/t-time",
    "txt" to "text/plain",
    "ult" to "audio/x-mod",
    "ustar" to "application/x-ustar",
    "uu" to "application/x-uuencode",
    "uue" to "application/x-uuencode",
    "vcd" to "application/x-cdlink",
    "vcf" to "text/x-vcard",
    "vdo" to "video/vdo",
    "vib" to "audio/vib",
    "viv" to "video/vivo",
    "vivo" to "video/vivo",
    "vmd" to "application/vocaltec-media-desc",
    "vmf" to "application/vocaltec-media-file",
    "vmi" to "application/x-dreamcast-vms-info",
    "vms" to "application/x-dreamcast-vms",
    "vox" to "audio/voxware",
    "vqe" to "audio/x-twinvq-plugin",
    "vqf" to "audio/x-twinvq",
    "vql" to "audio/x-twinvq",
    "vre" to "x-world/x-vream",
    "vrml" to "x-world/x-vrml",
    "vrt" to "x-world/x-vrt",
    "vrw" to "x-world/x-vream",
    "vts" to "workbook/formulaone",
    "wav" to "audio/x-wav",
    "wax" to "audio/x-ms-wax",
    "wbmp" to "image/vnd.wap.wbmp",
    "web" to "application/vnd.xara",
    "wi" to "image/wavelet",
    "wis" to "application/x-InstallShield",
    "wm" to "video/x-ms-wm",
    "wma" to "audio/x-ms-wma",
    "wmd" to "application/x-ms-wmd",
    "wmf" to "application/x-msmetafile",
    "wml" to "text/vnd.wap.wml",
    "wmlc" to "application/vnd.wap.wmlc",
    "wmls" to "text/vnd.wap.wmlscript",
    "wmlsc" to "application/vnd.wap.wmlscriptc",
    "wmlscript" to "text/vnd.wap.wmlscript",
    "wmv" to "audio/x-ms-wmv",
    "wmx" to "video/x-ms-wmx",
    "wmz" to "application/x-ms-wmz",
    "wpng" to "image/x-up-wpng",
    "wpt" to "x-lml/x-gps",
    "wri" to "application/x-mswrite",
    "wrl" to "x-world/x-vrml",
    "wrz" to "x-world/x-vrml",
    "ws" to "text/vnd.wap.wmlscript",
    "wsc" to "application/vnd.wap.wmlscriptc",
    "wv" to "video/wavelet",
    "wvx" to "video/x-ms-wvx",
    "wxl" to "application/x-wxl",
    "x-gzip" to "application/x-gzip",
    "xar" to "application/vnd.xara",
    "xbm" to "image/x-xbitmap",
    "xdm" to "application/x-xdma",
    "xdma" to "application/x-xdma",
    "xdw" to "application/vnd.fujixerox.docuworks",
    "xht" to "application/xhtml+xml",
    "xhtm" to "application/xhtml+xml",
    "xhtml" to "application/xhtml+xml",
    "xla" to "application/vnd.ms-excel",
    "xlc" to "application/vnd.ms-excel",
    "xll" to "application/x-excel",
    "xlm" to "application/vnd.ms-excel",
    "xls" to "application/vnd.ms-excel",
    "xlt" to "application/vnd.ms-excel",
    "xlw" to "application/vnd.ms-excel",
    "xm" to "audio/x-mod",
    "xml" to "text/xml",
    "xmz" to "audio/x-mod",
    "xpi" to "application/x-xpinstall",
    "xpm" to "image/x-xpixmap",
    "xsit" to "text/xml",
    "xsl" to "text/xml",
    "xul" to "text/xul",
    "xwd" to "image/x-xwindowdump",
    "xyz" to "chemical/x-pdb",
    "yz1" to "application/x-yz1",
    "z" to "application/x-compress",
    "zac" to "application/x-zaurus-zac",
    "zip" to "application/zip"
)
fun bitmapToBase64(bitmap: Bitmap): String = Base64.encodeToString(
    ByteArrayOutputStream().apply {
        bitmap.compress(Bitmap.CompressFormat.JPEG, 70, this)
        flush()
        close()
    }.toByteArray(), Base64.DEFAULT
)

fun Activity.display() = DisplayMetrics().apply {
    windowManager.defaultDisplay.getMetrics(this)
}

fun Context.dp2px(dp: Float) = (dp * resources.displayMetrics.density + 0.5).toInt()

fun Context.isPad()=
    ((resources.configuration.screenLayout and Configuration.SCREENLAYOUT_SIZE_MASK) >= Configuration.SCREENLAYOUT_SIZE_LARGE)

infix fun View.setDelayClickListener(clickAction: () -> Unit) {
    var hash = 0
    var lastClickTime = 0L
    val spaceTime = 1000L
    setOnClickListener {
        if (this.hashCode() != hash) {
            hash = this.hashCode()
            lastClickTime = System.currentTimeMillis()
            clickAction()
        } else {
            val currentTime = System.currentTimeMillis()
            if (currentTime - lastClickTime > spaceTime) {
                lastClickTime = System.currentTimeMillis()
                clickAction()
            }
        }
    }
}
fun <T> averageAssign(
    source: MutableList<T>?,
    splitItemNum: Int
): MutableList<MutableList<T>> {
    val result = mutableListOf<MutableList<T>>()

    if (!source.isNullOrEmpty() && splitItemNum > 0) {
        if (source.size <= splitItemNum) {
            // 源List元素数量小于等于目标分组数量
            result.add(source)
        } else {
            // 计算拆分后list数量
            val splitNum =
                if (source.size % splitItemNum == 0) source.size / splitItemNum else source.size / splitItemNum + 1

            for (i in 0 until splitNum) {
                result.add(
                    if (i < splitNum - 1) {
                        source.subList(i * splitItemNum, (i + 1) * splitItemNum)
                    } else {
                        // 最后一组
                        source.subList(i * splitItemNum, source.size)
                    }
                )
            }
        }
    }

    return result
}

/**
 * 去double小数点后的 0
 */
fun Double.removeDecimalZero(): String =
    DecimalFormat("##########.###").format(this)

/**
 * 获取时间
 * @param type 0(2020-01-01)、1(00:00:00)、else(2020-01-01 00:00:00)
 */
fun getFormatDate(date: Date? = Date(), type: Int = 0): String =
    if (date == null)
        ""
    else
        SimpleDateFormat(
            when (type) {
                0 -> "yyyy-MM-dd"
                1 -> "HH:mm:ss"
                2 -> "yyyyMMdd"//sap时间格式
                3 -> "yyyy-MM-dd HH:mm:ss"
                else -> "yyyy-MM-dd HH:mm:ss.SSS"
            }, Locale.CHINA
        ).format(date)


fun Double.add(value: Double) =
    BigDecimal(toString()).add(BigDecimal(value.toString())).toDouble()

fun Double.sub(value: Double) =
    BigDecimal(toString()).subtract(BigDecimal(value.toString())).toDouble()

fun Double.mul(value: Double) =
    BigDecimal(toString()).multiply(BigDecimal(value.toString())).toDouble()

fun Double.divide(value: Double) = BigDecimal(toString()).divide(
    BigDecimal(value.toString()), 21,
    RoundingMode.HALF_UP
).toDouble()

/**
 * 带异常捕获的toDouble
 */
fun String.toDoubleTry() = if (isNullOrEmpty()) {
    0.0
} else try {
    toDouble()
} catch (e: NumberFormatException) {
    0.0
}


/**
 * 使用自定义方法打开文件
 */
fun openFile(act: Context, file: File) {
    val intent = Intent()
    val authority = "${act.packageName}.FileProvider"
    Log.e("Pan","authority:$authority")
    Log.e("Pan","authority:$authority-----SDK:${Build.VERSION.SDK_INT}-----")
    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
        //  此处注意替换包名，
        val contentUri = FileProvider.getUriForFile(act, authority, file)
        intent.setDataAndType(contentUri, getFileMIME(file))
    } else {
        //也可使用 Uri.parse("file://"+file.getAbsolutePath());
        intent.setDataAndType(Uri.fromFile(file), getFileMIME(file))
    }

    //以下设置都不是必须的
    intent.action = Intent.ACTION_VIEW // 系统根据不同的Data类型，通过已注册的对应Application显示匹配的结果。
    intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK) //系统会检查当前所有已创建的Task中是否有该要启动的Activity的Task
    //若有，则在该Task上创建Activity；若没有则新建具有该Activity属性的Task，并在该新建的Task上创建Activity。
    intent.addCategory(Intent.CATEGORY_DEFAULT) //按照普通Activity的执行方式执行
    intent.addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
    act.startActivity(intent)
}

/**
 * 使用自定义方法获得文件的MIME类型
 */
private fun getFileMIME(file: File): String {
    var type = "*/*"
    val fName = file.name
    //获取后缀名前的分隔符"."在fName中的位置。
    val dotIndex = fName.lastIndexOf(".")
    if (dotIndex > 0) {
        //获取文件的后缀名
        val end = fName.substring(dotIndex, fName.length).lowercase(Locale.getDefault())
        //在MIME和文件类型的匹配表中找到对应的MIME类型。
        if (end.isNotEmpty() && fileIMEI_Simple.containsKey(end)) {
            type = fileIMEI_Simple[end].toString()
        }
    }
    Log.e("Pan","我定义的MIME类型为：$type")
    return type
}
