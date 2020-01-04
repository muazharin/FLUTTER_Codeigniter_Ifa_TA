<?php
defined('BASEPATH') or exit('No direct script access allowed');
class Api extends CI_Controller
{
    public function signup()
    {
        $username = $this->input->post('username');
        $email = $this->input->post('email');
        $hp = $this->input->post('hp');
        $password = md5($this->input->post('password'));
        $query1 = $this->db->query('SELECT * FROM tb_user WHERE username = "' . $username . '"');
        if ($query1->num_rows() <= 0) {
            $data = [
                'username' => $username,
                'email' => $email,
                'hp' => $hp,
                'password' => $password
            ];

            $query = $this->db->insert('tb_user', $data);
            if ($query) {
                $api = [
                    'message' => 'Account successfully added!',
                    'value' => '1'
                ];
            } else {
                $api = [
                    'message' => 'Account failed to add',
                    'value' => '1'
                ];
            }
        } else {
            $api = [
                'message' => 'Username is already exist! Please change to another one.',
                'value' => '0'
            ];
        }
        echo json_encode($api);
    }
    public function login()
    {
        $username = $this->input->post('username', true);
        $password = md5($this->input->post('password', true));
        $qwe = $this->db->query('SELECT * FROM tb_user WHERE username = "' . $username . '" AND password = "' . $password . '"');
        if ($qwe->num_rows() <= 0) {
            $data[] = [
                'value' => 0,
                'status' => 'login_gagal',
            ];
        } else {
            $a = $qwe->result();
            $data = array();
            foreach ($a as $r) {
                $data[] = [
                    'value' => 1,
                    'status' => 'login_berhasil',
                    'username' => $r->username,
                    'email' => $r->email,
                    'hp' => $r->hp
                ];
            }
        }
        echo json_encode($data);
    }
    public function gen()
    {
        $this->load->library('vigen');
        $id = $this->input->post('id', true);
        $nama = $this->input->post('nama', true);
        $tipe = $this->input->post('tipe', true);
        $str = $this->input->post('str', true);
        $key = $this->input->post('key', true);
        $v = $this->vigen->decrypt($key, $str);
        if ($tipe == 'img') {
            $v = pack("H*", $v);
            file_put_contents("assets/file_dec/" . $nama . $id . ".jpg", $v);
            $api = [
                'result' => $nama . $id . '.jpg'
            ];
        }
        //  else if ($tipe == 'mp4') {
        //     $v = pack("H*", $v);
        //     file_put_contents("assets/file_dec/" . $nama . $id . ".mp4", $v);
        //     $api = [
        //         'result' => $nama . $id . '.mp4'
        //     ];
        // }
        else if ($tipe == 'text') {
            $api = [
                'result' => $v
            ];
        }
        echo json_encode($api);
    }

    public function sendText()
    {
        $text = $this->input->post('text', true);
        $pengirim = $this->input->post('pengirim', true);
        $penerima = $this->input->post('penerima', true);
        $kunci = $this->input->post('kunci', true);
        $pesan = $this->input->post('pesan', true);
        $ket = $this->input->post('ket', true);
        $this->load->library('vigen');
        $str = $this->vigen->encrypt($kunci, $text);

        $data = [
            'pengirim' => $pengirim,
            'penerima' => $penerima,
            'kunci' => $kunci,
            'tipe' => 'text',
            'str' => $str,
            'pesan' => $pesan,
            'ket' => $ket
        ];
        if ($this->db->insert('tb_send', $data)) {
            $insert_id = $this->db->insert_id();
            $data2 = [
                'id_send' => $insert_id
            ];
            $this->db->insert('tb_recent', $data2);
            $data3 = [
                'id_send' => $insert_id,
                'ket_pengirim' => $pengirim,
                'ket_penerima' => $penerima
            ];
            $this->db->insert('tb_delete', $data3);
            $api = [
                'message' => 'Data has been sent'
            ];
        } else {
            $api = [
                'message' => 'Data failed to sent'
            ];
        }
        echo json_encode($api);
    }

    public function sendImage()
    {
        $this->load->library('vigen');
        $pengirim = $this->input->post('pengirim', true);
        $penerima = $this->input->post('penerima', true);
        $kunci = $this->input->post('kunci', true);
        $pesan = $this->input->post('pesan', true);
        $ket = $this->input->post('ket', true);
        $this->load->library('upload');
        $config['upload_path'] = './assets/file_kirim';
        $config['allowed_types'] = 'jpg|jpeg|png|gif|JPG|JPEG|PNG|GIF';
        $config['file_name'] = $_FILES['image']['name'];
        $this->upload->initialize($config);
        if (!empty($_FILES['image']['name'])) {
            if ($this->upload->do_upload('image')) {
                $foto = $this->upload->data();
                $hex = unpack("H*", file_get_contents('assets/file_kirim/' . $foto['file_name']));
                $hex = current($hex);
                $hex = $this->vigen->encrypt($kunci, $hex);
                file_put_contents("assets/file_enc/" . $foto['file_name'], $hex);
                $data = [
                    'pengirim' => $pengirim,
                    'penerima' => $penerima,
                    'kunci' => $kunci,
                    'tipe' => 'img',
                    'str' => $hex,
                    'pesan' => $pesan,
                    'ket' => $ket
                ];
                $this->db->insert('tb_send', $data);
                $insert_id = $this->db->insert_id();
                $data2 = [
                    'id_send' => $insert_id
                ];
                $this->db->insert('tb_recent', $data2);
                $data3 = [
                    'id_send' => $insert_id,
                    'ket_pengirim' => $pengirim,
                    'ket_penerima' => $penerima
                ];
                $this->db->insert('tb_delete', $data3);
                $api = [
                    'message' => 'Data has been sent'
                ];
            } else {
                $api = [
                    'message' => 'Data failed to sent'
                ];
            }
        }
        echo json_encode($api);
    }

    // public function sendVideo()
    // {
    //     $this->load->library('vigen');
    //     $pengirim = $this->input->post('pengirim', true);
    //     $penerima = $this->input->post('penerima', true);
    //     $kunci = $this->input->post('kunci', true);
    //     $pesan = $this->input->post('pesan', true);
    //     $ket = $this->input->post('ket', true);
    //     $this->load->library('upload');
    //     $config['upload_path'] = './assets/file_kirim';
    //     $config['allowed_types'] = 'mp4|MP4';
    //     $config['file_name'] = $_FILES['video']['name'];
    //     $this->upload->initialize($config);
    //     if (!empty($_FILES['video']['name'])) {
    //         if ($this->upload->do_upload('video')) {
    //             $foto = $this->upload->data();
    //             $hex = unpack("H*", file_get_contents('assets/file_kirim/' . $foto['file_name']));
    //             $hex = current($hex);
    //             $hex = $this->vigen->encrypt($kunci, $hex);
    //             file_put_contents("assets/file_enc/" . $foto['file_name'], $hex);
    //             $data = [
    //                 'pengirim' => $pengirim,
    //                 'penerima' => $penerima,
    //                 'kunci' => $kunci,
    //                 'tipe' => 'mp4',
    //                 'str' => $hex,
    //                 'pesan' => $pesan,
    //                 'ket' => $ket
    //             ];
    //             $this->db->insert('tb_send', $data);
    //             $insert_id = $this->db->insert_id();
    //             $data2 = [
    //                 'id_send' => $insert_id
    //             ];
    //             $this->db->insert('tb_recent', $data2);
    //             $data3 = [
    //                 'id_send' => $insert_id,
    //                 'ket_pengirim' => $pengirim,
    //                 'ket_penerima' => $penerima
    //             ];
    //             $this->db->insert('tb_delete', $data3);
    //             $api = [
    //                 'message' => 'Data has been sent'
    //             ];
    //         } else {
    //             $api = [
    //                 'message' => 'Data failed to sent'
    //             ];
    //         }
    //     }
    //     echo json_encode($api);
    // }

    public function getDataKirim()
    {
        $pengirim = $this->input->post('pengirim', true);
        $query = $this->db->query('SELECT a.* FROM tb_send a, tb_delete b WHERE a.id_send = b.id_send AND b.ket_pengirim = "' . $pengirim . '" ORDER BY a.id_send DESC ')->result();
        $api = array();
        foreach ($query as $q) {
            $api[] = [
                'id' => $q->id_send,
                'penerima' => $q->penerima,
                'kunci' => $q->kunci,
                'tipe' => $q->tipe,
                'str' => $q->str,
                'pesan' => $q->pesan,
                'ket' => $q->ket,
            ];
        }
        echo json_encode($api);
    }

    public function getDataInbox()
    {
        $penerima = $this->input->post('penerima', true);
        $query = $this->db->query('SELECT a.* FROM tb_send a, tb_delete b WHERE a.id_send = b.id_send AND b.ket_penerima = "' . $penerima . '" ORDER BY a.id_send DESC')->result();
        $api = array();
        foreach ($query as $q) {
            $api[] = [
                'id' => $q->id_send,
                'pengirim' => $q->pengirim,
                'kunci' => $q->kunci,
                'tipe' => $q->tipe,
                'str' => $q->str,
                'pesan' => $q->pesan,
                'ket' => $q->ket
            ];
        }
        echo json_encode($api);
    }

    public function getData()
    {
        $user = $this->input->post('user', true);
        $query = $this->db->query('SELECT * FROM tb_send LEFT JOIN tb_delete ON tb_send.id_send = tb_delete.id_send WHERE tb_delete.ket_pengirim="' . $user . '"')->num_rows();
        $query1 = $this->db->query('SELECT * FROM tb_send LEFT JOIN tb_delete ON tb_send.id_send = tb_delete.id_send WHERE tb_delete.ket_penerima="' . $user . '"')->num_rows();
        $api = [
            'send' => $query,
            'inbox' => $query1
        ];
        echo json_encode($api);
    }

    public function getRecent()
    {
        $user = $this->input->post('user', true);
        $query = $this->db->query('SELECT tb_send.id_send, tb_send.pengirim, tb_send.penerima, tb_send.tipe FROM tb_send LEFT JOIN tb_recent ON tb_send.id_send = tb_recent.id_send WHERE tb_send.pengirim="' . $user . '" ORDER BY id_send DESC LIMIT 10');
        $query1 = $query->result();
        foreach ($query1 as $q1) {
            $api[] = [
                'pengirim' => $q1->pengirim,
                'penerima' => $q1->penerima,
                'tipe' => $q1->tipe
            ];
        }
        echo json_encode($api);
    }

    public function deleteSend()
    {
        $id = $this->input->post('id_send');
        $query = $this->db->query('UPDATE tb_delete SET ket_pengirim="no" WHERE id_send = "' . $id . '"');
        if ($query) {
            $api = [
                'result' => 'Data successfully deleted!'
            ];
        } else {
            $api = [
                'result' => 'A delete error occurred'
            ];
        }
        echo json_encode($api);
    }

    public function deleteInbox()
    {
        $id = $this->input->post('id_send');
        $query = $this->db->query('UPDATE tb_delete SET ket_penerima="no" WHERE id_send = "' . $id . '"');
        if ($query) {
            $api = [
                'result' => 'Data successfully deleted!'
            ];
        } else {
            $api = [
                'result' => 'A delete error occurred'
            ];
        }
        echo json_encode($api);
    }


    // public function ta()
    // {
    //     $this->load->library('vigen');
    //     $a = $this->input->post('q', true);
    //     $k = 'qwe';
    //     $z = $this->vigen->decrypt($k, $a);
    //     echo $z;
    // }
}
